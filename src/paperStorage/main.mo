import Map "mo:base/HashMap";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";



import Types "../shared/Types";

actor PaperStorage {
    
type Paper = Types.Paper;
type PaperSubmission = Types.PaperSubmission;
type User = Types.User;
type Review = Types.Review;
type SearchQuery = Types.SearchQuery;
type PaginatedResult<T> = Types.PaginatedResult<T>;
type PaginationParams = Types.PaginationParams;
type Error = Types.Error;
type Result<T, E> = Types.Result<T, E>;

// Stable storage (arrays of key-value pairs)

// Stable storage: arrays of key-value pairs (stable types)
private stable var papersEntries : [(Text, Paper)] = [];
private stable var usersEntries : [(Principal, User)] = [];
private stable var reviewsEntries : [(Text, Review)] = [];
private stable var papersByAuthorEntries : [(Text, [Text])] = [];
private stable var papersByTagEntries : [(Text, [Text])] = [];
private stable var paperCounter : Nat = 0;
private stable var reviewCounter : Nat = 0;

// Runtime storage: HashMaps (not stable)
// Use a mutable variable for runtime (non-stable) storage
private var papers = Map.HashMap<Text, Paper>(0, Text.equal, Text.hash);
private var users = Map.HashMap<Principal, User>(0, Principal.equal, Principal.hash);
private var reviews = Map.HashMap<Text, Review>(0, Text.equal, Text.hash);
private var papersByAuthor = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);
private var papersByTag = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);

// Save HashMaps to stable arrays before upgrade
system func preupgrade() {
    papersEntries := Iter.toArray(papers.entries());
    usersEntries := Iter.toArray(users.entries());
    reviewsEntries := Iter.toArray(reviews.entries());
    papersByAuthorEntries := Iter.toArray(papersByAuthor.entries());
    papersByTagEntries := Iter.toArray(papersByTag.entries());
};

// Restore HashMaps from stable arrays after upgrade
system func postupgrade() {
    papers := Map.fromIter<Text, Paper>(papersEntries.vals(), papersEntries.size(), Text.equal, Text.hash);
    users := Map.fromIter<Principal, User>(usersEntries.vals(), usersEntries.size(), Principal.equal, Principal.hash);
    reviews := Map.fromIter<Text, Review>(reviewsEntries.vals(), reviewsEntries.size(), Text.equal, Text.hash);
    papersByAuthor := Map.fromIter<Text, [Text]>(papersByAuthorEntries.vals(), papersByAuthorEntries.size(), Text.equal, Text.hash);
    papersByTag := Map.fromIter<Text, [Text]>(papersByTagEntries.vals(), papersByTagEntries.size(), Text.equal, Text.hash);

    // Optionally clear the stable arrays to save memory
    papersEntries := [];
    usersEntries := [];
    reviewsEntries := [];
    papersByAuthorEntries := [];
    papersByTagEntries := [];
};

    // Helper function to convert text to lowercase
    private func textToLowercase(text: Text) : Text {
        Text.toLowercase(text)
    };

    // Private functions
    private func generatePaperId() : Text {
        paperCounter += 1;
        "paper_" # Nat.toText(paperCounter)
    };

    private func generateReviewId() : Text {
        reviewCounter += 1;
        "review_" # Nat.toText(reviewCounter)
    };

    private func addToAuthorIndex(paperId: Text, authors: [Text]) {
        for (author in authors.vals()) {
            switch (papersByAuthor.get(author)) {
                case null {
                    papersByAuthor.put(author, [paperId]);
                };
                case (?existingPapers) {
                    let updatedPapers = Array.append(existingPapers, [paperId]);
                    papersByAuthor.put(author, updatedPapers);
                };
            };
        };
    };

    private func addToTagIndex(paperId: Text, tags: [Text]) {
        for (tag in tags.vals()) {
            switch (papersByTag.get(tag)) {
                case null {
                    papersByTag.put(tag, [paperId]);
                };
                case (?existingPapers) {
                    let updatedPapers = Array.append(existingPapers, [paperId]);
                    papersByTag.put(tag, updatedPapers);
                };
            };
        };
    };

    private func arrayContainsText(arr: [Text], searchText: Text) : Bool {
        switch (Array.find<Text>(arr, func(item) { Text.equal(item, searchText) })) {
            case null false;
            case (?_) true;
        };
    };

    private func arrayContainsTextPartial(arr: [Text], searchText: Text) : Bool {
        let searchLower = textToLowercase(searchText);
        switch (Array.find<Text>(arr, func(item) { 
            let itemLower = textToLowercase(item);
            Text.contains(itemLower, #text searchLower)
        })) {
            case null false;
            case (?_) true;
        };
    };

    private func checkKeywords(paper: Paper, keywords: ?Text) : Bool {
        switch (keywords) {
            case null true;
            case (?keywordsText) {
                let keywordsLower = textToLowercase(keywordsText);
                let titleLower = textToLowercase(paper.title);
                let abstractLower = textToLowercase(paper.abstract);
                
                Text.contains(titleLower, #text keywordsLower) or Text.contains(abstractLower, #text keywordsLower)
            };
        };
    };

    private func checkTags(paper: Paper, queryTags: ?[Text]) : Bool {
        switch (queryTags) {
            case null true;
            case (?tags) {
                switch (Array.find<Text>(tags, func(tag) {
                    arrayContainsText(paper.tags, tag)
                })) {
                    case null false;
                    case (?_) true;
                };
            };
        };
    };

    private func checkAuthors(paper: Paper, queryAuthors: ?[Text]) : Bool {
        switch (queryAuthors) {
            case null true;
            case (?authors) {
                switch (Array.find<Text>(authors, func(author) {
                    arrayContainsTextPartial(paper.authors, author)
                })) {
                    case null false;
                    case (?_) true;
                };
            };
        };
    };

    private func checkInstitution(paper: Paper, institution: ?Text) : Bool {
        switch (institution) {
            case null true;
            case (?inst) {
                let paperInstLower = textToLowercase(paper.institution);
                let queryInstLower = textToLowercase(inst);
                Text.contains(paperInstLower, #text queryInstLower)
            };
        };
    };

    private func checkDateRange(paper: Paper, dateFrom: ?Int, dateTo: ?Int) : Bool {
        let fromCheck = switch (dateFrom) {
            case null true;
            case (?from) paper.publishedDate >= from;
        };
        
        let toCheck = switch (dateTo) {
            case null true;
            case (?to) paper.publishedDate <= to;
        };
        
        fromCheck and toCheck
    };

    private func checkStatus(paper: Paper, status: ?Types.PaperStatus) : Bool {
        switch (status) {
            case null true;
            case (?queryStatus) {
                switch (paper.status, queryStatus) {
                    case (#published, #published) true;
                    case (#under_review, #under_review) true;
                    case (#draft, #draft) true;
                    case _ false;
                };
            };
        };
    };

    private func matchesSearchQuery(paper: Paper, searchQuery: SearchQuery) : Bool {
        checkKeywords(paper, searchQuery.keywords) and
        checkTags(paper, searchQuery.tags) and
        checkAuthors(paper, searchQuery.authors) and
        checkInstitution(paper, searchQuery.institution) and
        checkDateRange(paper, searchQuery.dateFrom, searchQuery.dateTo) and
        checkStatus(paper, searchQuery.status)
    };

    // Public functions

    // User management
    public shared(msg) func registerUser(profile: Types.UserProfile) : async Result<User, Error> {
        let caller = msg.caller;
        
        switch (users.get(caller)) {
            case (?_) { #err(#AlreadyExists) };
            case null {
                let user : User = {
                    id = caller;
                    name = profile.name;
                    email = profile.email;
                    institution = profile.institution;
                    avatar = profile.avatar;
                    reputation = 0.0;
                    rezTokens = 1000; // Initial tokens
                    joinedAt = Time.now();
                    papersSubmitted = [];
                    papersReviewed = [];
                };
                users.put(caller, user);
                #ok(user)
            };
        };
    };

    public shared query(msg) func getUser() : async Result<User, Error> {
        switch (users.get(msg.caller)) {
            case (?user) #ok(user);
            case null #err(#NotFound);
        };
    };

    public shared(msg) func updateUserProfile(profile: Types.UserProfile) : async Result<User, Error> {
        switch (users.get(msg.caller)) {
            case null { #err(#NotFound) };
            case (?user) {
                let updatedUser = {
                    user with
                    name = profile.name;
                    email = profile.email;
                    institution = profile.institution;
                    avatar = profile.avatar;
                };
                users.put(msg.caller, updatedUser);
                #ok(updatedUser)
            };
        };
    };

    // Paper management
    public shared(msg) func submitPaper(submission: PaperSubmission) : async Result<Text, Error> {
        switch (users.get(msg.caller)) {
            case null { #err(#Unauthorized) };
            case (?currentUser) {
                let paperId = generatePaperId();
                let paper : Paper = {
                    id = paperId;
                    title = submission.title;
                    abstract = submission.abstract;
                    authors = submission.authors;
                    institution = submission.institution;
                    publishedDate = Time.now();
                    tags = submission.tags;
                    citations = 0;
                    downloads = 0;
                    doi = submission.doi;
                    status = #under_review;
                    fileUrl = ?("ipfs://paper_" # paperId); // Simulated IPFS storage
                    submitter = msg.caller;
                    reviewers = [];
                    reviewScore = 0.0;
                };

                papers.put(paperId, paper);
                addToAuthorIndex(paperId, submission.authors);
                addToTagIndex(paperId, submission.tags);

                // Update user's submitted papers
                let updatedUser = {
                    currentUser with
                    papersSubmitted = Array.append(currentUser.papersSubmitted, [paperId]);
                };
                users.put(msg.caller, updatedUser);

                #ok(paperId)
            };
        };
    };

    public shared query func getPaper(paperId: Text) : async Result<Paper, Error> {
        switch (papers.get(paperId)) {
            case (?paper) #ok(paper);
            case null #err(#NotFound);
        };
    };

    public shared query func getAllPapers(pagination: PaginationParams) : async PaginatedResult<Paper> {
        let allPapers = Iter.toArray(papers.vals());
        let sortedPapers = Array.sort<Paper>(
            allPapers,
            func(a, b) { Int.compare(b.publishedDate, a.publishedDate) }
        );
        
        let total = sortedPapers.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedPapers = if (start >= total) { 
            [] 
        } else {
            Array.subArray(sortedPapers, start, Int.abs(end - start))
        };

        {
            data = paginatedPapers;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

public shared query func searchPapers(Query: SearchQuery, pagination: PaginationParams) : async PaginatedResult<Paper> {
    let allPapers = do { Iter.toArray(papers.vals()) };
    let filteredPapers = Array.filter<Paper>(allPapers, func(paper) { 
        matchesSearchQuery(paper, Query); 
    });

    let sortedPapers = Array.sort<Paper>(
        filteredPapers,
        func(a, b) { Int.compare(b.publishedDate, a.publishedDate) }
    );

    let total = sortedPapers.size();
    let start = pagination.page * pagination.limit;
    let end = Int.min(start + pagination.limit, total);

    let paginatedPapers = if (start >= total) { 
        [] 
    } else {
        Array.subArray(sortedPapers, start, Int.abs(end - start))
    };

    {
        data = paginatedPapers;
        total = total;
        page = pagination.page;
        limit = pagination.limit;
        hasNext = end < total;
    }
};

public shared(_) func incrementDownloads(paperId: Text) : async Result<(), Error> {
    switch (papers.get(paperId)) {
        case null { #err(#NotFound) };
        case (?currentPaper) {
            let updatedPaper = { currentPaper with downloads = currentPaper.downloads + 1 };
            papers.put(paperId, updatedPaper);
            #ok(())
        };
    };
};

// Review system
public shared(msg) func submitReview(paperId: Text, score: Nat, comments: Text, isPublic: Bool) : async Result<Text, Error> {
    if (score < 1 or score > 10) {
        return #err(#InvalidInput("Score must be between 1 and 10"));
    };

    switch (papers.get(paperId)) {
        case null { #err(#NotFound) };
        case (?currentPaper) {
            switch (users.get(msg.caller)) {
                case null { #err(#Unauthorized) };
                case (?currentUser) {
                    let reviewId = generateReviewId();
                    let review : Review = {
                        id = reviewId;
                        paperId = paperId;
                        reviewer = msg.caller;
                        score = score;
                        comments = comments;
                        isPublic = isPublic;
                        timestamp = Time.now();
                    };

                    reviews.put(reviewId, review);

                    // Update paper with new reviewer
                    let updatedReviewers = Array.append(currentPaper.reviewers, [msg.caller]);
                    let updatedPaper = { currentPaper with reviewers = updatedReviewers };
                    papers.put(paperId, updatedPaper);

                    // Update user's reviewed papers
                    let updatedUser = {
                        currentUser with
                        papersReviewed = Array.append(currentUser.papersReviewed, [paperId]);
                        reputation = currentUser.reputation + 0.1; // Small reputation boost for reviewing
                    };
                    users.put(msg.caller, updatedUser);

                    #ok(reviewId)
                };
            };
        };
    };
};

public query func getReviewsForPaper(paperId: Text) : async [Review] {
    let allReviews = Iter.toArray(reviews.vals());
    Array.filter<Review>(allReviews, func(review) { 
        Text.equal(review.paperId, paperId) and review.isPublic 
    })
};
    // Statistics
    public shared query func getPaperStats() : async {totalPapers: Nat; publishedPapers: Nat; underReviewPapers: Nat} {
        let allPapers = Iter.toArray(papers.vals());
        let published = Array.filter<Paper>(allPapers, func(p) { 
            p.status == #published
        });
        let underReview = Array.filter<Paper>(allPapers, func(p) { 
            p.status == #under_review
        });

        {
            totalPapers = allPapers.size();
            publishedPapers = published.size();
            underReviewPapers = underReview.size();
        }
    };

    public shared query func getUserStats(userId: Principal) : async Result<{papersSubmitted: Nat; papersReviewed: Nat; reputation: Float}, Error> {
        switch (users.get(userId)) {
            case null { #err(#NotFound) };
            case (?currentUser) {
                #ok({
                    papersSubmitted = currentUser.papersSubmitted.size();
                    papersReviewed = currentUser.papersReviewed.size();
                    reputation = currentUser.reputation;
                })
            };
        };
    };

    // Admin functions
    public shared(msg) func updatePaperStatus(paperId: Text, status: Types.PaperStatus) : async Result<(), Error> {
        // Note: In a real implementation, this should have proper authorization
        switch (papers.get(paperId)) {
            case null { #err(#NotFound) };
            case (?currentPaper) {
                let updatedPaper = { currentPaper with status = status };
                papers.put(paperId, updatedPaper);
                #ok(())
            };
        };
    };

    // Utility functions
    public shared query func getPopularTags(limit: Nat) : async [(Text, Nat)] {
        let tagCounts = Buffer.Buffer<(Text, Nat)>(0);
        
        for ((tag, paperIds) in papersByTag.entries()) {
            tagCounts.add((tag, paperIds.size()));
        };

        let sortedTags = Array.sort<(Text, Nat)>(
            Buffer.toArray(tagCounts), 
            func(a, b) { Nat.compare(b.1, a.1) }
        );

        if (sortedTags.size() <= limit) {
            sortedTags
        } else {
            Array.subArray(sortedTags, 0, limit)
        }
    };

    public shared query func getTrendingPapers(limit: Nat) : async [Paper] {
        let allPapers = Iter.toArray(papers.vals());
        let sortedByDownloads = Array.sort<Paper>(
            allPapers, 
            func(a, b) { Nat.compare(b.downloads, a.downloads) }
        );

        if (sortedByDownloads.size() <= limit) {
            sortedByDownloads
        } else {
            Array.subArray(sortedByDownloads, 0, limit)
        }
}
};