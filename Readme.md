# 🎓 DeResNet - Decentralized Academic Research Platform

![DeResNet Logo](https://via.placeholder.com/600x200/4F46E5/FFFFFF?text=DeResNet)

[![Internet Computer](https://img.shields.io/badge/Internet%20Computer-Protocol-blue)](https://internetcomputer.org/)
[![Motoko](https://img.shields.io/badge/Language-Motoko-purple)](https://motoko.org/)
[![React](https://img.shields.io/badge/Frontend-React-61DAFB)](https://reactjs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

DeResNet is a revolutionary decentralized academic research platform built on the Internet Computer Protocol (ICP). It empowers researchers worldwide with transparent publishing, democratic governance, AI-powered insights, and seamless multi-chain integration.

## 🌟 Features

### 📚 **Research Paper Management**
- **Decentralized Publishing**: Submit and publish papers directly on-chain with immutable storage
- **Peer Review System**: Community-driven peer review with reputation scoring
- **Advanced Search**: Semantic search across papers with filtering and categorization
- **Citation Tracking**: Automated citation counting and academic impact metrics

### 🗳️ **DAO Governance**
- **Democratic Voting**: Token-based voting system for platform decisions
- **Research Grants**: Community-funded research proposal system
- **Transparent Process**: All votes and decisions recorded on-chain
- **Quorum Requirements**: Ensures meaningful community participation

### 🤖 **AI Research Assistant**
- **Paper Summarization**: Automatic generation of research paper summaries
- **Similarity Detection**: Find related papers based on content analysis
- **Research Insights**: AI-powered insights on research trends and gaps
- **Interactive Chat**: Natural language interface for research queries

### 🌉 **Multi-Chain Token Bridge**
- **Cross-Chain Support**: Bridge tokens from Ethereum, Bitcoin, and other chains
- **REZ Token Ecosystem**: Native utility token for platform governance and rewards
- **DeFi Integration**: Seamless integration with decentralized finance protocols

### 🔒 **Security & Transparency**
- **Internet Identity**: Secure authentication via ICP's Internet Identity
- **Immutable Storage**: Research papers stored permanently on-chain
- **Cryptographic Integrity**: All data protected by blockchain cryptography
- **Open Source**: Fully transparent and auditable codebase

## 🏗️ Architecture

DeResNet is built using a modular architecture with three main canisters:

```
┌─────────────────────────────────────────────────────┐
│                    Frontend                         │
│              React + TailwindCSS                    │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ @dfinity/agent
                  │
┌─────────────────┴───────────────────────────────────┐
│              Internet Computer                      │
│                                                     │
│  ┌───────────────┐ ┌───────────────┐ ┌─────────────┐│
│  │ paperStorage  │ │   daoSystem   │ │ aiChatbot   ││
│  │               │ │               │ │             ││
│  │ • Papers      │ │ • Proposals   │ │ • Chat      ││
│  │ • Reviews     │ │ • Voting      │ │ • Analysis  ││
│  │ • Users       │ │ • Tokens      │ │ • Insights  ││
│  └───────────────┘ └───────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────┘
```

### Core Canisters

1. **paperStorage**: Manages research papers, user profiles, and peer review system
2. **daoSystem**: Handles governance proposals, voting, and REZ token management  
3. **aiChatbot**: Provides AI-powered research assistance and paper analysis

## 🚀 Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) (v16 or higher)
- [DFINITY SDK](https://internetcomputer.org/docs/current/developer-docs/setup/install/)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/deresnet.git
   cd deresnet
   ```

2. **Run the setup script**
   ```bash
   chmod +x scripts/deploy.sh
   ./scripts/deploy.sh
   ```

3. **Start the development environment**
   ```bash
   npm run dev
   ```

The application will be available at `http://localhost:4943/?canisterId=<frontend-canister-id>`

### Manual Setup

If you prefer manual setup:

1. **Install dependencies**
   ```bash
   npm run setup:deps
   ```

2. **Create development identity**
   ```bash
   npm run setup:identity
   ```

3. **Start local replica**
   ```bash
   dfx start --background --clean
   ```

4. **Deploy canisters**
   ```bash
   dfx deploy
   ```

5. **Initialize with test data**
   ```bash
   dfx canister call daoSystem initializeTokens
   dfx canister call paperStorage registerUser '(record {
     name = "Dr. Test User";
     email = "test@deresnet.org"; 
     institution = "DeResNet Foundation";
     avatar = null;
   })'
   ```

## 🧪 Testing

Run the comprehensive test suite:

```bash
chmod +x scripts/test.sh
./scripts/test.sh
```

The test suite includes:
- Unit tests for all canister functions
- Integration tests for cross-canister workflows
- Performance tests for bulk operations
- Error handling validation

## 📋 Usage Examples

### Submitting a Research Paper

```bash
dfx canister call paperStorage submitPaper '(record {
  title = "Quantum Computing in Climate Science";
  abstract = "This paper explores applications of quantum computing...";
  authors = vec { "Dr. Alice Johnson"; "Prof. Bob Smith" };
  institution = "MIT";
  tags = vec { "quantum"; "climate"; "computing" };
  doi = opt "10.1000/example.123";
  fileData = blob "PDF content here...";
  category = "computer-science";
})'
```

### Creating a DAO Proposal

```bash
dfx canister call daoSystem createProposal '(record {
  title = "Research Grant for AI Safety";
  description = "Proposal to fund AI safety research...";
  proposalType = variant { grant };
  requiredTokens = 100;
  duration = 604800000000000;
})'
```

### Interacting with AI Assistant

```bash
# Create chat session
dfx canister call aiChatbot createChatSession

# Send message
dfx canister call aiChatbot sendMessage '(
  "session_1",
  "Summarize recent quantum computing papers",
  null
)'
```

### Voting on Proposals

```bash
dfx canister call daoSystem vote '("proposal_1", true)'
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Network configuration
DFX_NETWORK=local
CANISTER_PAPERSTORAGE=<canister-id>
CANISTER_DAOSYSTEM=<canister-id>
CANISTER_AICHATBOT=<canister-id>

# Frontend configuration
REACT_APP_IC_HOST=http://localhost:4943
REACT_APP_ENVIRONMENT=development
```

### Canister Configuration

The `dfx.json` file defines the canister configuration:

```json
{
  "canisters": {
    "paperStorage": {
      "type": "motoko",
      "main": "src/paperStorage/main.mo"
    },
    "daoSystem": {
      "type": "motoko", 
      "main": "src/daoSystem/main.mo"
    },
    "aiChatbot": {
      "type": "motoko",
      "main": "src/aiChatbot/main.mo"
    }
  }
}
```

## 📊 API Reference

### PaperStorage Canister

| Function | Description | Parameters |
|----------|-------------|------------|
| `registerUser` | Register a new user | `UserProfile` |
| `submitPaper` | Submit a research paper | `PaperSubmission` |
| `getPaper` | Retrieve a paper by ID | `Text` |
| `searchPapers` | Search papers with filters | `SearchQuery, PaginationParams` |
| `submitReview` | Submit peer review | `Text, Nat, Text, Bool` |

### DAOSystem Canister

| Function | Description | Parameters |
|----------|-------------|------------|
| `createProposal` | Create governance proposal | `ProposalSubmission` |
| `vote` | Vote on a proposal | `Text, Bool` |
| `getTokenBalance` | Get user's token balance | None |
| `transferTokens` | Transfer tokens | `Principal, Nat` |

### AIChatbot Canister

| Function | Description | Parameters |
|----------|-------------|------------|
| `createChatSession` | Start new chat session | None |
| `sendMessage` | Send message to AI | `Text, Text, ?Text` |
| `analyzePaper` | Analyze paper content | `Text, Text` |
| `findSimilarPapers` | Find similar papers | `Text` |

## 🚀 Deployment

### Local Deployment

```bash
./scripts/deploy.sh --network local
```

### IC Mainnet Deployment

```bash
./scripts/deploy.sh --network ic
```

### Production Checklist

Before deploying to mainnet:

- [ ] Run full test suite
- [ ] Review security considerations
- [ ] Configure proper access controls
- [ ] Set up monitoring and alerts
- [ ] Prepare upgrade procedures

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

### Code Style

- Follow Motoko style guidelines
- Use meaningful variable names
- Add comprehensive comments
- Include type annotations

## 🛡️ Security

### Reporting Security Issues

Please report security vulnerabilities to security@deresnet.org

### Security Features

- **Internet Identity**: Secure authentication without passwords
- **Canister Security**: Proper access controls and validation
- **Data Integrity**: Cryptographic verification of all data
- **Upgrade Safety**: Secure canister upgrade procedures

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [DFINITY Foundation](https://dfinity.org/) for the Internet Computer Protocol
- [Motoko Language](https://motoko.org/) for the programming language
- The research community for inspiration and feedback

## 📞 Support

- **Documentation**: [docs.deresnet.org](https://docs.deresnet.org)
- **Community Discord**: [discord.gg/deresnet](https://discord.gg/deresnet)
- **Email Support**: support@deresnet.org
- **GitHub Issues**: [GitHub Issues](https://github.com/your-org/deresnet/issues)

## 🗺️ Roadmap

### Phase 1 (Current)
- ✅ Core platform functionality
- ✅ Basic DAO governance
- ✅ AI research assistant
- ✅ Multi-chain bridge

### Phase 2 (Q2 2024)
- 🔄 Advanced peer review algorithms
- 🔄 Enhanced AI capabilities
- 🔄 Mobile application
- 🔄 API marketplace

### Phase 3 (Q3 2024)
- 📅 Institutional partnerships
- 📅 Advanced analytics dashboard
- 📅 Research collaboration tools
- 📅 NFT certificates

### Phase 4 (Q4 2024)
- 📅 Cross-platform integrations
- 📅 Advanced governance features
- 📅 Global expansion
- 📅 Enterprise solutions

---

**Built with ❤️ on the Internet Computer Protocol**

*Empowering researchers worldwide through decentralization*