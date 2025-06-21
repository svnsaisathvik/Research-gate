import Time "mo:base/Time";
import Principal "mo:base/Principal";

module {
    
    // Paper related types
    public type PaperStatus = {
        #published;
        #under_review;
        #draft;
    };

    public type Paper = {
        id: Text;
        title: Text;
        abstract: Text;
        authors: [Text];
        institution: Text;
        publishedDate: Int; // Unix timestamp
        tags: [Text];
        citations: Nat;
        downloads: Nat;
        doi: ?Text;
        status: PaperStatus;
        fileUrl: ?Text;
        submitter: Principal;
        reviewers: [Principal];
        reviewScore: Float;
    };

    public type PaperSubmission = {
        title: Text;
        abstract: Text;
        authors: [Text];
        institution: Text;
        tags: [Text];
        doi: ?Text;
        fileData: Blob;
        category: Text;
    };

    // User related types
    public type User = {
        id: Principal;
        name: Text;
        email: Text;
        institution: Text;
        avatar: ?Text;
        reputation: Float;
        rezTokens: Nat;
        joinedAt: Int;
        papersSubmitted: [Text];
        papersReviewed: [Text];
    };

    public type UserProfile = {
        name: Text;
        email: Text;
        institution: Text;
        avatar: ?Text;
    };

    // DAO related types
    public type ProposalType = {
        #grant;
        #review;
        #governance;
    };

    public type ProposalStatus = {
        #active;
        #passed;
        #rejected;
        #executed;
    };

    public type Vote = {
        voter: Principal;
        choice: Bool; // true for 'for', false for 'against'
        power: Nat; // voting power based on REZ tokens
        timestamp: Int;
    };

    public type Proposal = {
        id: Text;
        title: Text;
        description: Text;
        proposalType: ProposalType;
        proposer: Principal;
        votesFor: Nat;
        votesAgainst: Nat;
        totalVotes: Nat;
        endDate: Int;
        status: ProposalStatus;
        requiredTokens: Nat;
        votes: [Vote];
        createdAt: Int;
        executedAt: ?Int;
    };

    public type ProposalSubmission = {
        title: Text;
        description: Text;
        proposalType: ProposalType;
        requiredTokens: Nat;
        duration: Int; // Duration in nanoseconds
    };

    // AI Chat related types
    public type MessageType = {
        #user;
        #ai;
    };

    public type ChatMessage = {
        id: Text;
        messageType: MessageType;
        content: Text;
        timestamp: Int;
        userId: Principal;
        paperRef: ?Text;
    };

    public type ChatSession = {
        id: Text;
        userId: Principal;
        messages: [ChatMessage];
        createdAt: Int;
        lastActivity: Int;
    };

    // Token and transaction types
    public type TokenTransaction = {
        id: Text;
        from: Principal;
        to: Principal;
        amount: Nat;
        transactionType: Text; // "transfer", "reward", "vote", etc.
        timestamp: Int;
        metadata: ?Text;
    };

    // Review types
    public type Review = {
        id: Text;
        paperId: Text;
        reviewer: Principal;
        score: Nat; // 1-10 rating
        comments: Text;
        isPublic: Bool;
        timestamp: Int;
    };

    // Error types
    public type Error = {
        #NotFound;
        #Unauthorized;
        #InvalidInput: Text;
        #InsufficientTokens;
        #AlreadyExists;
        #NotImplemented;
    };

    // Response types
    public type Result<T, E> = {
        #ok: T;
        #err: E;
    };

    // Search and filter types
    public type SearchQuery = {
        keywords: ?Text;
        tags: ?[Text];
        authors: ?[Text];
        institution: ?Text;
        dateFrom: ?Int;
        dateTo: ?Int;
        status: ?PaperStatus;
    };

    public type PaginationParams = {
        page: Nat;
        limit: Nat;
    };

    public type PaginatedResult<T> = {
        data: [T];
        total: Nat;
        page: Nat;
        limit: Nat;
        hasNext: Bool;
    };
}