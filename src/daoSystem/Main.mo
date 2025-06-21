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


import Types "../shared/Types";

actor DAOSystem {
    
    type Proposal = Types.Proposal;
    type ProposalSubmission = Types.ProposalSubmission;
    type Vote = Types.Vote;
    type TokenTransaction = Types.TokenTransaction;
    type User = Types.User;
    type Error = Types.Error;
    type Result<T, E> = Types.Result<T, E>;
    type PaginatedResult<T> = Types.PaginatedResult<T>;
    type PaginationParams = Types.PaginationParams;

    // Stable storage
    private stable var proposalsEntries : [(Text, Proposal)] = [];
    private stable var tokenBalancesEntries : [(Principal, Nat)] = [];
    private stable var transactionsEntries : [(Text, TokenTransaction)] = [];
    private stable var proposalCounter : Nat = 0;
    private stable var transactionCounter : Nat = 0;
    private stable var totalTokenSupply : Nat = 1000000; // 1M REZ tokens total supply

    // Runtime storage
    private var proposals = Map.HashMap<Text, Proposal>(0, Text.equal, Text.hash);
    private var tokenBalances = Map.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    private var transactions = Map.HashMap<Text, TokenTransaction>(0, Text.equal, Text.hash);
    private var userVotes = Map.HashMap<Principal, [Text]>(0, Principal.equal, Principal.hash); // User -> [ProposalIds]

    // Constants
    private let INITIAL_TOKEN_AMOUNT : Nat = 1000;
    private let _MIN_PROPOSAL_TOKENS : Nat = 100;
    private let _PROPOSAL_DURATION_DAYS : Int = 7 * 24 * 60 * 60 * 1000000000; // 7 days in nanoseconds
    private let QUORUM_PERCENTAGE : Float = 0.1; // 10% of token holders must participate

    // Initialize from stable storage
    system func preupgrade() {
        proposalsEntries := Iter.toArray(proposals.entries());
        tokenBalancesEntries := Iter.toArray(tokenBalances.entries());
        transactionsEntries := Iter.toArray(transactions.entries());
    };

    system func postupgrade() {
        proposals := Map.fromIter<Text, Proposal>(proposalsEntries.vals(), proposalsEntries.size(), Text.equal, Text.hash);
        tokenBalances := Map.fromIter<Principal, Nat>(tokenBalancesEntries.vals(), tokenBalancesEntries.size(), Principal.equal, Principal.hash);
        transactions := Map.fromIter<Text, TokenTransaction>(transactionsEntries.vals(), transactionsEntries.size(), Text.equal, Text.hash);
        proposalsEntries := [];
        tokenBalancesEntries := [];
        transactionsEntries := [];
    };

    // Private functions
    private func generateProposalId() : Text {
        proposalCounter += 1;
        "proposal_" # Nat.toText(proposalCounter)
    };

    private func generateTransactionId() : Text {
        transactionCounter += 1;
        "tx_" # Nat.toText(transactionCounter)
    };

    private func getTokenBalance(user: Principal) : Nat {
        switch (tokenBalances.get(user)) {
            case (?balance) balance;
            case null 0;
        };
    };

    private func updateTokenBalance(user: Principal, newBalance: Nat) {
        tokenBalances.put(user, newBalance);
    };

    private func recordTransaction(from: Principal, to: Principal, amount: Nat, txType: Text, metadata: ?Text) : Text {
        let txId = generateTransactionId();
        let transaction : TokenTransaction = {
            id = txId;
            from = from;
            to = to;
            amount = amount;
            transactionType = txType;
            timestamp = Time.now();
            metadata = metadata;
        };
        transactions.put(txId, transaction);
        txId
    };

    private func hasUserVoted(userId: Principal, proposalId: Text) : Bool {
        switch (userVotes.get(userId)) {
            case null false;
            case (?votedProposals) {
                Array.find<Text>(votedProposals, func(id) { Text.equal(id, proposalId) }) != null
            };
        };
    };

    private func addUserVote(userId: Principal, proposalId: Text) {
        switch (userVotes.get(userId)) {
            case null {
                userVotes.put(userId, [proposalId]);
            };
            case (?existing) {
                let updated = Array.append(existing, [proposalId]);
                userVotes.put(userId, updated);
            };
        };
    };

    private func calculateVotingPower(tokenBalance: Nat) : Nat {
        // Simple linear voting power based on tokens
        // Could implement more complex mechanisms like quadratic voting
        tokenBalance / 10 // 1 voting power per 10 tokens
    };

    private func isProposalActive(proposal: Proposal) : Bool {
        Time.now() < proposal.endDate and proposal.status == #active
    };

    private func checkAndUpdateProposalStatus(proposalId: Text) : async () {
        switch (proposals.get(proposalId)) {
            case null {};
            case (?proposal) {
                if (proposal.status == #active and Time.now() >= proposal.endDate) {
                    let totalVotingPower = proposal.votesFor + proposal.votesAgainst;
                    let requiredQuorum = Float.fromInt(Int.abs(Float.toInt(Float.fromInt(totalTokenSupply) * QUORUM_PERCENTAGE)));
                    
                    let newStatus = if (Float.fromInt(totalVotingPower) >= requiredQuorum and proposal.votesFor > proposal.votesAgainst) {
                        #passed
                    } else {
                        #rejected
                    };

                    let updatedProposal = { proposal with status = newStatus };
                    proposals.put(proposalId, updatedProposal);
                };
            };
        };
    };

    // Token management
    public shared(msg) func initializeTokens() : async Result<Nat, Error> {
        let caller = msg.caller;
        let currentBalance = getTokenBalance(caller);
        
        if (currentBalance == 0) {
            updateTokenBalance(caller, INITIAL_TOKEN_AMOUNT);
            let _ = recordTransaction(Principal.fromText("2vxsx-fae"), caller, INITIAL_TOKEN_AMOUNT, "initialize", null);
            #ok(INITIAL_TOKEN_AMOUNT)
        } else {
            #ok(currentBalance)
        }
    };

    public shared query(msg) func getMyTokenBalance() : async Nat {
        getTokenBalance(msg.caller)
    };

    public shared(msg) func transferTokens(to: Principal, amount: Nat) : async Result<Text, Error> {
        let caller = msg.caller;
        let senderBalance = getTokenBalance(caller);
        
        if (senderBalance < amount) {
            return #err(#InsufficientTokens);
        };

        let recipientBalance = getTokenBalance(to);
        
        updateTokenBalance(caller, senderBalance - amount);
        updateTokenBalance(to, recipientBalance + amount);
        
        let txId = recordTransaction(caller, to, amount, "transfer", null);
        #ok(txId)
    };

    public shared(msg) func rewardTokens(to: Principal, amount: Nat, reason: Text) : async Result<Text, Error> {
        // This should have proper authorization in production
        let recipientBalance = getTokenBalance(to);
        updateTokenBalance(to, recipientBalance + amount);
        
        let txId = recordTransaction(msg.caller, to, amount, "reward", ?reason);
        #ok(txId)
    };

    // Proposal management
    public shared(msg) func createProposal(submission: ProposalSubmission) : async Result<Text, Error> {
        let caller = msg.caller;
        let callerBalance = getTokenBalance(caller);
        
        if (callerBalance < submission.requiredTokens) {
            return #err(#InsufficientTokens);
        };

        let proposalId = generateProposalId();
        let endDate = Time.now() + submission.duration;
        
        let proposal : Proposal = {
            id = proposalId;
            title = submission.title;
            description = submission.description;
            proposalType = submission.proposalType;
            proposer = caller;
            votesFor = 0;
            votesAgainst = 0;
            totalVotes = 0;
            endDate = endDate;
            status = #active;
            requiredTokens = submission.requiredTokens;
            votes = [];
            createdAt = Time.now();
            executedAt = null;
        };

        proposals.put(proposalId, proposal);
        #ok(proposalId)
    };

    public shared query func getProposal(proposalId: Text) : async Result<Proposal, Error> {
        switch (proposals.get(proposalId)) {
            case (?proposal) #ok(proposal);
            case null #err(#NotFound);
        };
    };

    public shared query func getAllProposals(pagination: PaginationParams) : async PaginatedResult<Proposal> {
        let allProposals = Iter.toArray(proposals.vals());
        let sortedProposals = Array.sort<Proposal>(
            allProposals,
            func(a, b) { Int.compare(b.createdAt, a.createdAt) }
        );
        
        let total = sortedProposals.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedProposals = if (start >= total) { [] } else {
            Array.subArray(sortedProposals, start, Int.abs(end - start))
        };

        {
            data = paginatedProposals;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    public shared query func getProposalsByStatus(status: Types.ProposalStatus, pagination: PaginationParams) : async PaginatedResult<Proposal> {
        let allProposals = Iter.toArray(proposals.vals());
        let filteredProposals = Array.filter<Proposal>(allProposals, func(p) {
            switch (p.status, status) {
                case (#active, #active) true;
                case (#passed, #passed) true;
                case (#rejected, #rejected) true;
                case (#executed, #executed) true;
                case _ false;
            };
        });
        
        let sortedProposals = Array.sort<Proposal>(
            filteredProposals,
            func(a, b) { Int.compare(b.createdAt, a.createdAt) }
        );
        
        let total = sortedProposals.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedProposals = if (start >= total) { [] } else {
            Array.subArray(sortedProposals, start, Int.abs(end - start))
        };

        {
            data = paginatedProposals;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    // Voting
    public shared(msg) func vote(proposalId: Text, choice: Bool) : async Result<(), Error> {
        let caller = msg.caller;
        let callerBalance = getTokenBalance(caller);
        
        switch (proposals.get(proposalId)) {
            case null { #err(#NotFound) };
            case (?proposal) {
                if (not isProposalActive(proposal)) {
                    return #err(#InvalidInput("Proposal is not active"));
                };

                if (callerBalance < proposal.requiredTokens) {
                    return #err(#InsufficientTokens);
                };

                if (hasUserVoted(caller, proposalId)) {
                    return #err(#InvalidInput("User has already voted"));
                };

                let votingPower = calculateVotingPower(callerBalance);
                let vote : Vote = {
                    voter = caller;
                    choice = choice;
                    power = votingPower;
                    timestamp = Time.now();
                };

                let updatedVotes = Array.append(proposal.votes, [vote]);
                let updatedVotesFor = if (choice) { proposal.votesFor + votingPower } else { proposal.votesFor };
                let updatedVotesAgainst = if (not choice) { proposal.votesAgainst + votingPower } else { proposal.votesAgainst };

                let updatedProposal = {
                    proposal with
                    votes = updatedVotes;
                    votesFor = updatedVotesFor;
                    votesAgainst = updatedVotesAgainst;
                    totalVotes = proposal.totalVotes + votingPower;
                };

                proposals.put(proposalId, updatedProposal);
                addUserVote(caller, proposalId);

                let _ = recordTransaction(caller, Principal.fromText("2vxsx-fae"), 0, "vote", ?("Voted on proposal: " # proposalId));
                
                await checkAndUpdateProposalStatus(proposalId);
                #ok(())
            };
        };
    };

    public shared query(msg) func getUserVotes() : async [Text] {
        switch (userVotes.get(msg.caller)) {
            case null [];
            case (?votes) votes;
        };
    };

    public shared query(msg) func hasVoted(proposalId: Text) : async Bool {
        hasUserVoted(msg.caller, proposalId)
    };

    // Execution
    public shared(_) func executeProposal(proposalId: Text) : async Result<(), Error> {
        switch (proposals.get(proposalId)) {
            case null { #err(#NotFound) };
            case (?proposal) {
                if (proposal.status != #passed) {
                    return #err(#InvalidInput("Proposal must be in passed status"));
                };

                // Execute proposal logic based on type
                switch (proposal.proposalType) {
                    case (#grant) {
                        // For grant proposals, transfer tokens to proposer
                        let grantAmount = 1000; // This should be extracted from proposal
                        let proposerBalance = getTokenBalance(proposal.proposer);
                        updateTokenBalance(proposal.proposer, proposerBalance + grantAmount);
                        let _ = recordTransaction(Principal.fromText("2vxsx-fae"), proposal.proposer, grantAmount, "grant", ?("Grant from proposal: " # proposalId));
                    };
                    case (#governance) {
                        // Governance proposals would update system parameters
                        // Implementation depends on specific governance actions
                    };
                    case (#review) {
                        // Review proposals might update review standards or processes
                        // Implementation depends on specific review actions
                    };
                };

                let updatedProposal = {
                    proposal with
                    status = #executed;
                    executedAt = ?Time.now();
                };
                proposals.put(proposalId, updatedProposal);
                #ok(())
            };
        };
    };

    // Statistics and utilities
    public shared query func getDAOStats() : async {
        totalProposals: Nat;
        activeProposals: Nat;
        passedProposals: Nat;
        totalTokenSupply: Nat;
        totalTokenHolders: Nat;
    } {
        let allProposals = Iter.toArray(proposals.vals());
        let activeProposals = Array.filter<Proposal>(allProposals, func(p) { p.status == #active });
        let passedProposals = Array.filter<Proposal>(allProposals, func(p) { p.status == #passed or p.status == #executed });

        {
            totalProposals = allProposals.size();
            activeProposals = activeProposals.size();
            passedProposals = passedProposals.size();
            totalTokenSupply = totalTokenSupply;
            totalTokenHolders = tokenBalances.size();
        }
    };

    public shared query func getTransactionHistory(pagination: PaginationParams) : async PaginatedResult<TokenTransaction> {
        let allTransactions = Iter.toArray(transactions.vals());
        let sortedTransactions = Array.sort<TokenTransaction>(
            allTransactions,
            func(a, b) { Int.compare(b.timestamp, a.timestamp) }
        );
        
        let total = sortedTransactions.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedTransactions = if (start >= total) { [] } else {
            Array.subArray(sortedTransactions, start, Int.abs(end - start))
        };

        {
            data = paginatedTransactions;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    public shared query(msg) func getUserTransactions(pagination: PaginationParams) : async PaginatedResult<TokenTransaction> {
        let allTransactions = Iter.toArray(transactions.vals());
        let userTransactions = Array.filter<TokenTransaction>(allTransactions, func(tx) {
            Principal.equal(tx.from, msg.caller) or Principal.equal(tx.to, msg.caller)
        });
        
        let sortedTransactions = Array.sort<TokenTransaction>(
            userTransactions,
            func(a, b) { Int.compare(b.timestamp, a.timestamp) }
        );
        
        let total = sortedTransactions.size();
        let start = pagination.page * pagination.limit;
        let end = Int.min(start + pagination.limit, total);
        
        let paginatedTransactions = if (start >= total) { [] } else {
            Array.subArray(sortedTransactions, start, Int.abs(end - start))
        };

        {
            data = paginatedTransactions;
            total = total;
            page = pagination.page;
            limit = pagination.limit;
            hasNext = end < total;
        }
    };

    // Admin functions (should have proper access control in production)
    public shared func updateTotalSupply(newSupply: Nat) : async () {
        totalTokenSupply := newSupply;
    };

    public shared func mintTokens(to: Principal, amount: Nat) : async Text {
        let recipientBalance = getTokenBalance(to);
        updateTokenBalance(to, recipientBalance + amount);
        totalTokenSupply += amount;
        recordTransaction(Principal.fromText("2vxsx-fae"), to, amount, "mint", null)
    };

    // Periodic task to update expired proposals
    public func updateExpiredProposals() : async () {
        for ((id, proposal) in proposals.entries()) {
            if (proposal.status == #active and Time.now() >= proposal.endDate) {
                await checkAndUpdateProposalStatus(id);
            };
        };
    };
}