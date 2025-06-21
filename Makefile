# DeResNet Makefile
# Provides convenient commands for development, testing, and deployment

.PHONY: help install clean start stop deploy test lint format check build dev logs

# Default target
help: ## Show this help message
	@echo "DeResNet Development Commands"
	@echo "=============================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup and Installation
install: ## Install all dependencies
	@echo "📦 Installing dependencies..."
	npm install
	cd deresnet-frontend && npm install
	@echo "✅ Dependencies installed"

setup: install ## Setup development environment
	@echo "🔧 Setting up development environment..."
	dfx identity new deresnet-dev --storage-mode plaintext || true
	dfx identity use deresnet-dev
	@echo "✅ Development environment ready"

# Development Commands
start: ## Start local dfx replica
	@echo "🚀 Starting local DFX replica..."
	dfx start --background --clean

stop: ## Stop local dfx replica
	@echo "🛑 Stopping DFX replica..."
	dfx stop

clean: stop ## Clean all build artifacts and restart fresh
	@echo "🧹 Cleaning build artifacts..."
	rm -rf .dfx
	rm -rf node_modules
	rm -rf deresnet-frontend/node_modules
	rm -rf deresnet-frontend/dist
	rm -rf deresnet-frontend/.next
	@echo "✅ Cleanup complete"

# Build Commands
build: ## Build all canisters
	@echo "🔨 Building canisters..."
	dfx build

build-frontend: ## Build frontend only
	@echo "🔨 Building frontend..."
	cd deresnet-frontend && npm run build

# Deployment Commands
deploy: build ## Deploy all canisters to local network
	@echo "🚀 Deploying to local network..."
	dfx deploy --network local

deploy-ic: build ## Deploy all canisters to IC mainnet
	@echo "🚀 Deploying to IC mainnet..."
	@read -p "Are you sure you want to deploy to mainnet? [y/N] " confirm && [ "$$confirm" = "y" ]
	dfx deploy --network ic --with-cycles 5000000000000

deploy-canister: ## Deploy specific canister (usage: make deploy-canister CANISTER=paperStorage)
	@echo "🚀 Deploying $(CANISTER)..."
	dfx deploy $(CANISTER) --network local

# Development Workflow
dev: start deploy ## Start development environment (start + deploy)
	@echo "🎉 Development environment ready!"
	@echo "Frontend: http://localhost:4943/?canisterId=$$(dfx canister id deresnet_frontend)"
	@echo "Candid UI: http://localhost:4943/?canisterId=$$(dfx canister id __Candid_UI)"

# Testing Commands
test: ## Run all tests
	@echo "🧪 Running all tests..."
	chmod +x scripts/test.sh
	./scripts/test.sh

test-backend: ## Run backend tests only
	@echo "🧪 Running backend tests..."
	dfx test

test-frontend: ## Run frontend tests only
	@echo "🧪 Running frontend tests..."
	cd deresnet-frontend && npm test

test-e2e: ## Run end-to-end tests
	@echo "🧪 Running E2E tests..."
	cd deresnet-frontend && npm run test:e2e

# Code Quality Commands
lint: ## Run linting for all code
	@echo "🔍 Running linters..."
	cd deresnet-frontend && npm run lint

lint-fix: ## Fix linting issues automatically
	@echo "🔧 Fixing linting issues..."
	cd deresnet-frontend && npm run lint:fix

format: ## Format all code
	@echo "💅 Formatting code..."
	cd deresnet-frontend && npm run format

check: lint test ## Run all code quality checks

# Canister Management
generate: ## Generate canister declarations
	@echo "📝 Generating canister declarations..."
	dfx generate

upgrade: ## Upgrade all canisters
	@echo "⬆️ Upgrading canisters..."
	dfx canister install --all --mode upgrade

reinstall: ## Reinstall all canisters (destructive)
	@echo "♻️ Reinstalling canisters..."
	@read -p "This will destroy all canister data. Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	dfx canister install --all --mode reinstall

# Data Management
init-data: ## Initialize canisters with test data
	@echo "🗃️ Initializing test data..."
	dfx canister call daoSystem initializeTokens
	dfx canister call paperStorage registerUser '(record { name = "Dr. Test User"; email = "test@deresnet.org"; institution = "DeResNet Foundation"; avatar = null; })'
	dfx canister call daoSystem createProposal '(record { title = "Test Proposal"; description = "A test proposal for development"; proposalType = variant { grant }; requiredTokens = 100; duration = 604800000000000; })'
	@echo "✅ Test data initialized"

backup-data: ## Backup canister data
	@echo "💾 Backing up canister data..."
	mkdir -p backups
	dfx canister call paperStorage getAllPapers '(record { page = 0; limit = 1000 })' > backups/papers_$$(date +%Y%m%d_%H%M%S).txt
	dfx canister call daoSystem getAllProposals '(record { page = 0; limit = 1000 })' > backups/proposals_$$(date +%Y%m%d_%H%M%S).txt
	@echo "✅ Data backed up to backups/ directory"

# Monitoring and Debugging
logs: ## Show recent logs
	@echo "📊 Showing recent logs..."
	dfx start --background 2>/dev/null || true
	sleep 2
	tail -f .dfx/local/replica.log

status: ## Show canister status
	@echo "📊 Canister Status:"
	@echo "=================="
	dfx canister status paperStorage || echo "paperStorage: Not deployed"
	dfx canister status daoSystem || echo "daoSystem: Not deployed"
	dfx canister status aiChatbot || echo "aiChatbot: Not deployed"
	dfx canister status deresnet_frontend || echo "frontend: Not deployed"

info: ## Show deployment info
	@echo "ℹ️ Deployment Information:"
	@echo "=========================="
	@echo "Network: $$(dfx ping 2>/dev/null && echo 'Local replica running' || echo 'Local replica not running')"
	@echo "Identity: $$(dfx identity whoami)"
	@echo "Principal: $$(dfx identity get-principal)"
	@echo ""
	@echo "Canister IDs:"
	@dfx canister id paperStorage 2>/dev/null && echo "paperStorage: $$(dfx canister id paperStorage)" || echo "paperStorage: Not deployed"
	@dfx canister id daoSystem 2>/dev/null && echo "daoSystem: $$(dfx canister id daoSystem)" || echo "daoSystem: Not deployed"
	@dfx canister id aiChatbot 2>/dev/null && echo "aiChatbot: $$(dfx canister id aiChatbot)" || echo "aiChatbot: Not deployed"
	@dfx canister id deresnet_frontend 2>/dev/null && echo "frontend: $$(dfx canister id deresnet_frontend)" || echo "frontend: Not deployed"

cycles: ## Show canister cycles balance
	@echo "💰 Cycles Balance:"
	@echo "=================="
	@dfx canister status paperStorage 2>/dev/null | grep -i cycles || echo "paperStorage: Not deployed"
	@dfx canister status daoSystem 2>/dev/null | grep -i cycles || echo "daoSystem: Not deployed"
	@dfx canister status aiChatbot 2>/dev/null | grep -i cycles || echo "aiChatbot: Not deployed"

# Performance and Analytics
perf-test: ## Run performance tests
	@echo "⚡ Running performance tests..."
	@echo "Submitting multiple papers..."
	@for i in $$(seq 1 10); do \
		dfx canister call paperStorage submitPaper "(record { title = \"Performance Test Paper $$i\"; abstract = \"This is a performance test\"; authors = vec { \"Test Author\" }; institution = \"Test University\"; tags = vec { \"performance\" }; doi = null; fileData = blob \"test\"; category = \"test\"; })" > /dev/null; \
	done
	@echo "✅ Performance test completed"

benchmark: ## Run benchmark tests
	@echo "📊 Running benchmarks..."
	time dfx canister call paperStorage getAllPapers '(record { page = 0; limit = 100 })'
	time dfx canister call daoSystem getAllProposals '(record { page = 0; limit = 100 })'
	@echo "✅ Benchmarks completed"

# Utility Commands
reset: clean setup start deploy init-data ## Complete reset and setup
	@echo "🔄 Complete reset finished"

quick-start: start deploy ## Quick start for development
	@echo "⚡ Quick start completed"

docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	cd deresnet-frontend && npm run docs || echo "Docs generation not configured"

# CI/CD Commands
ci-test: ## Run tests in CI environment
	dfx start --background --clean
	sleep 10
	dfx deploy
	chmod +x scripts/test.sh
	./scripts/test.sh
	dfx stop

# Security Commands
audit: ## Run security audit
	@echo "🔒 Running security audit..."
	npm audit
	cd deresnet-frontend && npm audit

fix-vulnerabilities: ## Fix known vulnerabilities
	@echo "🔧 Fixing vulnerabilities..."
	npm audit fix
	cd deresnet-frontend && npm audit fix

# Environment Commands
env-local: ## Switch to local environment
	@echo "🏠 Switching to local environment..."
	export DFX_NETWORK=local

env-ic: ## Switch to IC mainnet environment
	@echo "🌐 Switching to IC mainnet environment..."
	export DFX_NETWORK=ic

# Help for common workflows
help-dev: ## Show development workflow help
	@echo "🚀 Development Workflow:"
	@echo "======================="
	@echo "1. make setup      - First time setup"
	@echo "2. make dev        - Start development environment"
	@echo "3. make test       - Run tests"
	@echo "4. make lint       - Check code quality"
	@echo "5. make deploy     - Deploy changes"
	@echo ""
	@echo "Quick commands:"
	@echo "- make reset       - Complete reset and setup"
	@echo "- make quick-start - Fast development start"
	@echo "- make check       - Run all quality checks"

# Variables for parameterized commands
CANISTER ?= paperStorage
NETWORK ?= local
CYCLES ?= 1000000000000