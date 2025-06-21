import Map "mo:base/HashMap";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

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

    // Stable storage
    private stable var papersEntries : [(Text, Paper)] = [];
    private stable var usersEntries : [(Principal, User)] = [];
    private stable var reviewsEntries : [(Text, Review)] = [];
    private stable var paperCounter : Nat = 0;
    private stable var reviewCounter : Nat = 0;

    // Runtime storage
    private var papers = Map.HashMap<Text, Paper>(0, Text.equal, Text.hash);
    private var users = Map.HashMap<Principal, User>(0, Principal.equal, Principal.hash);
    private var reviews = Map.HashMap<Text, Review>(0, Text.equal, Text.hash);
    private var papersByAuthor = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);
    private var papersByTag = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);

    // Initialize from stable storage
    system func preupgrade() {
        papersEntries := Iter.toArray(papers.entries());
        usersEntries := Iter.toArray(users.entries());
        reviewsEntries := Iter.toArray(reviews.entries());
    };

    system func postupgrade() {
        papers := Map.fromIter<Text, Paper>(papersEntries.vals(), papersEntries.size(), Text.equal, Text.hash);
        users := Map.fromIter<Principal, User>(usersEntries.vals(), usersEntries.size(), Principal.equal, Principal.hash);
        reviews := Map.fromIter<Text, Review>(reviewsEntries.vals(), reviewsEntries.size(), Text.equal, Text.hash);
        papersEntries := [];
        usersEntries := [];
        reviewsEntries := [];
        rebuildIndices();
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

    private func rebuildIndices() {
        // Rebuild author index
        for ((id, paper) in papers.entries()) {
            for (author in paper.authors.vals()) {
                switch (papersByAuthor.get(author)) {
                    case null { papersByAuthor.put(author, [id]); };
                    case (?existing) { 
                        let updated = Array.append(existing, [id]);
                        papersByAuthor.put(author, updated);
                    };
                };
            };
        };

        // Rebuild tag index
        for ((id, paper) in papers.entries()) {
            for (tag in paper.tags.vals()) {
                switch (papersByTag.get(tag)) {
                    case null { papersByTag.put(tag, [id]); };
                    case (?existing) { 
                        let updated = Array.append(existing, [id]);
                        papersByTag.put(tag, updated);
                    };
                };
            };
        };
    };

    private func addToAuthorIndex(paperId: Text, authors: [Text]) {
        for (author in authors.vals()) {
            switch (papersByAuthor.get(author)) {
                case null { papersByAuthor.put(author, [paperId]); };
                case (?existing) { 
                    let updated = Array.append(existing, [paperId]);
                    papersByAuthor.put(author, updated);
                };
            };
        };
    };

    private func addToTagIndex(paperId: Text, tags: [Text]) {
        for (tag in tags.vals()) {
            switch (papersByTag.get(tag)) {
                case null { papersByTag.put(tag, [paperId]); };
                case (?existing) { 
                    let updated = Array.append(existing, [paperId]);
                    papersByTag.put(tag, updated);
                };
            };
        };
    };

    private func matchesSearchQuery(paper: Paper, query: SearchQuery) : Bool {
        // Check keywords
        switch (query.keywords) {
            case (?keywords) {
                let keywordsLower = Text.map(keywords, Prim.charToLower);
                let titleLower = Text.map(paper.title, Prim.charToLower);
                let abstractLower = Text.map(paper.abstract, Prim.charToLower);
                
                if (not (Text.contains(titleLower, #text keywordsLower) or 
                        Text.contains(abstractLower, #text keywordsLower))) {
                    return false;
                };
            };
            case null {};
        };

        // Check tags
        switch (query.tags) {
            case (?queryTags) {
                let hasMatchingTag = Array.find<Text>(queryTags, func(tag) {
                    Array.find<Text>(paper.tags, func(paperTag) { Text.equal(tag, paperTag) }) != null
                });
                if (hasMatchingTag == null) { return false; };
            };
            case null {};
        };

        // Check authors
        switch (query.authors) {
            case (?queryAuthors) {
                let hasMatchingAuthor = Array.find<Text>(queryAuthors, func(author) {
                    Array.find<Text>(paper.authors, func(paperAuthor) { 
                        Text.contains(Text.map(paperAuthor, Prim.charToLower), #text Text.map(author, Prim.charToLower))
                    }) != null
                });
                if (hasMatchingAuthor == null) { return false; };
            };
            case null {};
        };

        // Check institution
        switch (query.institution) {
            case (?inst) {
                if (not Text.contains(Text.map(paper.institution, Prim.charToLower), #text Text.map(inst, Prim.charToLower))) {
                    return false;
                };
            };
            case null {};
        };

        // Check date range
        switch (query.dateFrom) {
            case (?dateFrom) {
                if (paper.publishedDate < dateFrom) { return false; };
            };
            case null {};
        };

        switch (query.dateTo) {
            case (?dateTo) {
                if (paper.publishedDate > dateTo) { return false; };
            };
            case null {};
        };

        // Check status
        switch (query.status) {
            case (?status) {
                switch (paper.status, status) {
                    case (#published, #published) { true };
                    case (#under_review, #under_review) { true };
                    case (#draft, #draft) { true };
                    case _ { return false; };
                };
            };
            case null {};
        };

        true
    };

    // Public functions

    // User management
    public shared(msg) func registerUser(profile: Types.UserProfile) : async Result<User, Error> {
        let caller = msg.caller;
        
        switch (users.get(caller)) {
            case (?existing) { #err(#AlreadyExists) };
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
            case (?user) { #ok(user) };
            case null { #err(#NotFound) };
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
            case (?user) {
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
                    user with
                    papersSubmitted = Array.append(user.papersSubmitted, [paperId]);
                };
                users.put(msg.caller, updatedUser);

                #ok(paperId)
            };
        };
    };

    public shared query func getPaper(paperId: Text) : async Result<Paper, Error> {
        switch (papers.get(paperId)) {
            case (?paper) { #ok(paper) };
            case null { #err(#NotFound) };
        };
    };

    public shared query func getAllPapers(pagination: PaginationParams) : async PaginatedResult<Paper> {
        let allPapers = Iter.toArray(papers.vals());
        let total = allPapers.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedPapers = if (start >= total) { [] } else {
            Array.subArray(allPapers, start, end - start)
        };

        {
            data = paginatedPapers;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    public shared query func searchPapers(query: SearchQuery, pagination: PaginationParams) : async PaginatedResult<Paper> {
        let allPapers = Iter.toArray(papers.vals());
        let filteredPapers = Array.filter<Paper>(allPapers, func(paper) { matchesSearchQuery(paper, query) });
        let total = filteredPapers.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedPapers = if (start >= total) { [] } else {
            Array.subArray(filteredPapers, start, end - start)
        };

        {
            data = paginatedPapers;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    public shared(msg) func incrementDownloads(paperId: Text) : async Result<(), Error> {
        switch (papers.get(paperId)) {
            case null { #err(#NotFound) };
            case (?paper) {
                let updatedPaper = { paper with downloads = paper.downloads + 1 };
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
            case (?paper) {
                switch (users.get(msg.caller)) {
                    case null { #err(#Unauthorized) };
                    case (?user) {
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
                        let updatedReviewers = Array.append(paper.reviewers, [msg.caller]);
                        let updatedPaper = { paper with reviewers = updatedReviewers };
                        papers.put(paperId, updatedPaper);

                        // Update user's reviewed papers
                        let updatedUser = {
                            user with
                            papersReviewed = Array.append(user.papersReviewed, [paperId]);
                            reputation = user.reputation + 0.1; // Small reputation boost for reviewing
                        };
                        users.put(msg.caller, updatedUser);

                        #ok(reviewId)
                    };
                };
            };
        };
    };

    public shared query func getReviewsForPaper(paperId: Text) : async [Review] {
        let allReviews = Iter.toArray(reviews.vals());
        Array.filter<Review>(allReviews, func(review) { 
            Text.equal(review.paperId, paperId) and review.isPublic 
        })
    };

    // Statistics
    public shared query func getPaperStats() : async {totalPapers: Nat; publishedPapers: Nat; underReviewPapers: Nat} {
        let allPapers = Iter.toArray(papers.vals());
        let published = Array.filter<Paper>(allPapers, func(p) { 
            switch (p.status) { case (#published) true; case _ false; }
        });
        let underReview = Array.filter<Paper>(allPapers, func(p) { 
            switch (p.status) { case (#under_review) true; case _ false; }
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
            case (?user) {
                #ok({
                    papersSubmitted = user.papersSubmitted.size();
                    papersReviewed = user.papersReviewed.size();
                    reputation = user.reputation;
                })
            };
        };
    };

    // Admin functions
    public shared(msg) func updatePaperStatus(paperId: Text, status: Types.PaperStatus) : async Result<(), Error> {
        // Note: In a real implementation, this should have proper authorization
        switch (papers.get(paperId)) {
            case null { #err(#NotFound) };
            case (?paper) {
                let updatedPaper = { paper with status = status };
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
    };
}