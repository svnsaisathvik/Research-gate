# DeResNet Technical Documentation

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Canister Design](#canister-design)
3. [Data Models](#data-models)
4. [API Specifications](#api-specifications)
5. [Security Considerations](#security-considerations)
6. [Performance Optimizations](#performance-optimizations)
7. [Development Guidelines](#development-guidelines)
8. [Deployment Guide](#deployment-guide)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Troubleshooting](#troubleshooting)

## Architecture Overview

### System Architecture

DeResNet follows a modular microservices architecture built on the Internet Computer Protocol (ICP). The system consists of three main backend canisters and a React frontend application.

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend Layer                       │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │    React    │  │ TailwindCSS │  │ TypeScript  │      │
│  │ Application │  │   Styling   │  │ Type Safety │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │ 
└─────────────────┬───────────────────────────────────────┘
                  │
                  │ @dfinity/agent (Actor Model)
                  │
┌─────────────────┴───────────────────────────────────────┐
│                Internet Computer                        │
│                                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐     │
│  │paperStorage  │ │  daoSystem   │ │  aiChatbot   │     │
│  │              │ │              │ │              │     │
│  │• User Mgmt   │ │• Governance  │ │• Chat Sessions│    │
│  │• Papers      │ │• Proposals   │ │• AI Analysis │     │
│  │• Reviews     │ │• Voting      │ │• Summaries   │     │
│  │• Search      │ │• REZ Tokens  │ │• Insights    │     │
│  └──────────────┘ └──────────────┘ └──────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Backend**: Motoko smart contracts on Internet Computer
- **Frontend**: React 18 + TypeScript + TailwindCSS
- **Authentication**: Internet Identity
- **State Management**: React Context API + Custom Hooks
- **Build Tools**: Vite + DFX
- **Testing**: Jest (Frontend) + DFX Test (Backend)

### Design Principles

1. **Modularity**: Each canister has a single responsibility
2. **Scalability**: Horizontal scaling through multiple canisters
3. **Security**: Immutable storage and cryptographic verification
4. **Decentralization**: No single point of failure
5. **User Experience**: Web2-like UX with Web3 benefits

## Canister Design

### PaperStorage Canister

**Purpose**: Manages research papers, user profiles, and peer review system.

**Key Features**:
- User registration and profile management
- Paper submission and storage
- Peer review system
- Search and filtering capabilities
- Citation tracking

**Storage Strategy**:
- HashMap-based runtime storage for fast access
- Stable storage for persistence across upgrades
- Indexed storage for efficient searching

**Scalability Considerations**:
- Pagination for large result sets
- Lazy loading of paper content
- Efficient indexing by tags, authors, and institutions

### DAOSystem Canister

**Purpose**: Handles governance, voting, and REZ token management.

**Key Features**:
- REZ token minting and transfers
- Proposal creation and management
- Voting mechanism with token-based power
- Automatic proposal execution
- Transaction history

**Token Economics**:
- Initial supply: 1,000,000 REZ tokens
- Distribution: Research rewards, governance participation
- Voting power: 1 vote per 10 REZ tokens
- Quorum requirement: 10% of token holders must participate

### AIChatbot Canister

**Purpose**: Provides AI-powered research assistance and paper analysis.

**Key Features**:
- Chat session management
- Paper content analysis
- Research insights generation
- Similar paper recommendations
- Natural language processing

**AI Capabilities**:
- Intent classification
- Entity extraction
- Content summarization
- Similarity analysis
- Trend identification

## Data Models

### Core Types

```motoko
// User representation
type User = {
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

// Research paper
type Paper = {
    id: Text;
    title: Text;
    abstract: Text;
    authors: [Text];
    institution: Text;
    publishedDate: Int;
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

// DAO proposal
type Proposal = {
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
```

### State Management

Each canister maintains its state using:
- **Runtime Storage**: HashMap-based in-memory storage for fast access
- **Stable Storage**: Persistent storage that survives upgrades
- **Indices**: Optimized data structures for searching and filtering

### Data Relationships

```
Users ──┬── Papers (1:N)
        ├── Reviews (1:N)  
        ├── Proposals (1:N)
        └── Votes (1:N)

Papers ──┬── Reviews (1:N)
         └── AI Analysis (1:1)

Proposals ── Votes (1:N)
```

## API Specifications

### PaperStorage API

#### User Management

```motoko
// Register a new user
registerUser(profile: UserProfile) : async Result<User, Error>

// Get current user profile
getUser() : async Result<User, Error> query

// Update user profile
updateUserProfile(profile: UserProfile) : async Result<User, Error>
```

#### Paper Management

```motoko
// Submit a new paper
submitPaper(submission: PaperSubmission) : async Result<Text, Error>

// Get paper by ID
getPaper(paperId: Text) : async Result<Paper, Error> query

// Search papers with filters
searchPapers(query: SearchQuery, pagination: PaginationParams) : async PaginatedResult<Paper> query

// Get all papers with pagination
getAllPapers(pagination: PaginationParams) : async PaginatedResult<Paper> query
```

### DAOSystem API

#### Token Management

```motoko
// Initialize user tokens
initializeTokens() : async Result<Nat, Error>

// Get user's token balance
getTokenBalance() : async Nat query

// Transfer tokens to another user
transferTokens(to: Principal, amount: Nat) : async Result<Text, Error>
```

#### Governance

```motoko
// Create a new proposal
createProposal(submission: ProposalSubmission) : async Result<Text, Error>

// Vote on a proposal
vote(proposalId: Text, choice: Bool) : async Result<(), Error>

// Get all proposals
getAllProposals(pagination: PaginationParams) : async PaginatedResult<Proposal> query
```

### AIChatbot API

#### Chat Management

```motoko
// Create a new chat session
createChatSession() : async Result<Text, Error>

// Send a message in a chat session
sendMessage(sessionId: Text, content: Text, paperRef: ?Text) : async Result<ChatMessage, Error>

// Get user's chat sessions
getUserSessions() : async [ChatSession] query
```

#### AI Analysis

```motoko
// Analyze a research paper
analyzePaper(paperId: Text, paperContent: Text) : async Result<Text, Error>

// Get paper summary
getPaperSummary(paperId: Text) : async Result<Text, Error> query

// Find similar papers
findSimilarPapers(paperId: Text) : async Result<[Text], Error>
```

## Security Considerations

### Authentication and Authorization

1. **Internet Identity Integration**
   - Secure, passwordless authentication
   - Cryptographic key-based identity
   - No personal data stored on-chain

2. **Principal-based Access Control**
   - Each user identified by unique Principal
   - Function-level access controls
   - Owner-only operations for sensitive functions

3. **Input Validation**
   ```motoko
   // Example validation pattern
   private func validatePaperSubmission(submission: PaperSubmission) : Result<(), Text> {
       switch (Utils.validateRequired(submission.title, "Title")) {
           case (#err(msg)) { #err(msg) };
           case (#ok()) {
               switch (Utils.validateLength(submission.title, 1, 200, "Title")) {
                   case (#err(msg)) { #err(msg) };
                   case (#ok()) { #ok(()) };
               };
           };
       };
   };
   ```

### Data Integrity

1. **Immutable Storage**
   - Research papers stored permanently on-chain
   - Version control for paper updates
   - Cryptographic hashing for content verification

2. **Atomic Operations**
   - Transaction-like operations for consistency
   - Rollback mechanisms for failed operations
   - State validation before commits

3. **Access Patterns**
   ```motoko
   // Only paper submitter can update
   if (not Principal.equal(caller, paper.submitter)) {
       return #err(#Unauthorized);
   };
   ```

### Upgrade Safety

1. **Stable Storage Patterns**
   ```motoko
   system func preupgrade() {
       papersEntries := Iter.toArray(papers.entries());
   };

   system func postupgrade() {
       papers := Map.fromIter(papersEntries.vals(), ...);
       papersEntries := [];
   };
   ```

2. **Migration Strategies**
   - Schema versioning
   - Backward compatibility
   - Gradual migration for large datasets

## Performance Optimizations

### Query Optimization

1. **Indexing Strategy**
   ```motoko
   // Maintain indices for common queries
   private var papersByAuthor = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);
   private var papersByTag = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);
   ```

2. **Pagination**
   ```motoko
   public func getAllPapers(pagination: PaginationParams) : async PaginatedResult<Paper> {
       let start = pagination.page * pagination.limit;
       let end = Int.min(start + pagination.limit, total);
       // Return subset with pagination metadata
   };
   ```

3. **Caching**
   - Runtime caching for frequently accessed data
   - Lazy loading for expensive operations
   - Memory management for large datasets

### Memory Management

1. **Efficient Data Structures**
   - HashMap for O(1) lookups
   - Buffer for dynamic arrays
   - Minimal data copying

2. **Resource Limits**
   - Instruction count optimization
   - Memory usage monitoring
   - Cycles cost optimization

## Development Guidelines

### Code Organization

```
src/
├── shared/
│   ├── Types.mo          # Shared type definitions
│   └── Utils.mo          # Common utility functions
├── paperStorage/
│   └── main.mo          # PaperStorage canister
├── daoSystem/
│   └── main.mo          # DAOSystem canister
├── aiChatbot/
│   └── main.mo          # AIChatbot canister
└── declarations/        # Generated Candid interfaces
```

### Coding Standards

1. **Naming Conventions**
   - `camelCase` for variables and functions
   - `PascalCase` for types and modules
   - `UPPER_CASE` for constants

2. **Documentation**
   ```motoko
   /// Submits a new research paper to the platform
   /// @param submission: Paper details and content
   /// @returns: Result with paper ID or error
   public shared(msg) func submitPaper(submission: PaperSubmission) : async Result<Text, Error>
   ```

3. **Error Handling**
   ```motoko
   // Use Result types for error handling
   public type Result<T, E> = {
       #ok: T;
       #err: E;
   };
   ```

### Testing Strategy

1. **Unit Tests**
   ```bash
   # Test individual functions
   dfx canister call paperStorage submitPaper '(...)'
   dfx canister call paperStorage getPaper '("paper_1")'
   ```

2. **Integration Tests**
   ```bash
   # Test cross-canister workflows
   ./scripts/test.sh
   ```

3. **Performance Tests**
   ```bash
   # Load testing
   make perf-test
   ```

## Deployment Guide

### Local Development

1. **Setup**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

2. **Development Workflow**
   ```bash
   make dev                # Start development environment
   make test              # Run tests
   make deploy            # Deploy changes
   ```

### IC Mainnet Deployment

1. **Prerequisites**
   ```bash
   # Ensure sufficient cycles
   dfx ledger account-id
   dfx ledger transfer <cycles-wallet> --amount 10.0
   ```

2. **Deployment**
   ```bash
   dfx deploy --network ic --with-cycles 5000000000000
   ```

3. **Post-deployment**
   ```bash
   # Set controllers
   dfx canister --network ic update-settings paperStorage --add-controller <principal>
   ```

### Environment Configuration

```bash
# Production environment variables
export DFX_NETWORK=ic
export CANISTER_ID_PAPERSTORAGE=<canister-id>
export CANISTER_ID_DAOSYSTEM=<canister-id>
export CANISTER_ID_AICHATBOT=<canister-id>
```

## Monitoring and Logging

### Canister Metrics

1. **Cycles Monitoring**
   ```bash
   dfx canister status paperStorage --network ic
   ```

2. **Memory Usage**
   ```motoko
   // Monitor memory usage in code
   Debug.print("Memory usage: " # debug_show(Prim.rts_memory_size()));
   ```

3. **Performance Metrics**
   - Query response times
   - Update operation latency
   - Storage growth rates

### Logging Strategy

```motoko
// Structured logging
Utils.logInfo("Paper submitted: " # paperId # " by " # Principal.toText(caller));
Utils.logError("Failed to submit paper: " # errorMessage);
```

### Health Checks

```bash
# Automated health monitoring
dfx canister call paperStorage getPaperStats
dfx canister call daoSystem getDAOStats
dfx canister call aiChatbot getChatStats
```

## Troubleshooting

### Common Issues

1. **Canister Not Responding**
   ```bash
   # Check canister status
   dfx canister status <canister-name>
   
   # Restart if needed
   dfx canister stop <canister-name>
   dfx canister start <canister-name>
   ```

2. **Insufficient Cycles**
   ```bash
   # Add cycles to canister
   dfx canister deposit-cycles 1000000000000 <canister-name>
   ```

3. **Upgrade Failures**
   ```bash
   # Check upgrade compatibility
   dfx canister install <canister-name> --mode upgrade --argument '()'
   ```

### Debug Techniques

1. **Logging**
   ```motoko
   Debug.print("Debug: " # debug_show(value));
   ```

2. **State Inspection**
   ```bash
   # Call query functions to inspect state
   dfx canister call paperStorage getPaperStats
   ```

3. **Error Analysis**
   ```motoko
   // Detailed error messages
   #err(#InvalidInput("Title must be between 1 and 200 characters"))
   ```

### Performance Issues

1. **Slow Queries**
   - Check indexing strategy
   - Optimize data structures
   - Implement pagination

2. **Memory Exhaustion**
   - Monitor memory usage
   - Implement data cleanup
   - Optimize storage patterns

3. **High Cycles Consumption**
   - Profile expensive operations
   - Optimize algorithms
   - Cache frequently accessed data

---

For more detailed information, refer to the [API Documentation](./API.md) and [User Guide](./USER_GUIDE.md).