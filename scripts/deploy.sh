#!/bin/bash

# DeResNet Deployment Script
# This script deploys the DeResNet platform to Internet Computer

set -e

echo "🚀 Starting DeResNet deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if dfx is installed
if ! command -v dfx &> /dev/null; then
    print_error "dfx is not installed. Please install the DFINITY SDK first."
    print_status "Visit: https://internetcomputer.org/docs/current/developer-docs/setup/install/"
    exit 1
fi

# Check if node is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

print_success "Environment checks passed ✓"

# Parse command line arguments
NETWORK="local"
SKIP_FRONTEND=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --network)
            NETWORK="$2"
            shift 2
            ;;
        --skip-frontend)
            SKIP_FRONTEND=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --network NETWORK    Deploy to network (local|ic) [default: local]"
            echo "  --skip-frontend      Skip frontend deployment"
            echo "  --clean              Clean previous deployment"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_status "Deploying to network: $NETWORK"

# Clean previous deployment if requested
if [[ "$CLEAN" == true ]]; then
    print_status "Cleaning previous deployment..."
    dfx stop 2>/dev/null || true
    rm -rf .dfx 2>/dev/null || true
    print_success "Cleanup completed"
fi

# Start dfx if deploying locally
if [[ "$NETWORK" == "local" ]]; then
    print_status "Starting local dfx replica..."
    dfx start --background --clean
    
    # Wait for replica to be ready
    print_status "Waiting for replica to be ready..."
    sleep 5
fi

# Create identity if it doesn't exist
if ! dfx identity list | grep -q "deresnet-dev"; then
    print_status "Creating development identity..."
    dfx identity new deresnet-dev
fi

dfx identity use deresnet-dev
print_success "Using identity: $(dfx identity whoami)"

# Install dependencies
print_status "Installing dependencies..."
npm install

if [[ "$SKIP_FRONTEND" == false ]]; then
    cd deresnet-frontend
    npm install
    cd ..
fi

print_success "Dependencies installed"

# Build and deploy canisters
print_status "Building and deploying canisters..."

# Deploy paperStorage canister
print_status "Deploying paperStorage canister..."
dfx deploy paperStorage --network $NETWORK
PAPER_CANISTER_ID=$(dfx canister id paperStorage --network $NETWORK)
print_success "paperStorage deployed: $PAPER_CANISTER_ID"

# Deploy daoSystem canister  
print_status "Deploying daoSystem canister..."
dfx deploy daoSystem --network $NETWORK
DAO_CANISTER_ID=$(dfx canister id daoSystem --network $NETWORK)
print_success "daoSystem deployed: $DAO_CANISTER_ID"

# Deploy aiChatbot canister
print_status "Deploying aiChatbot canister..."
dfx deploy aiChatbot --network $NETWORK
AI_CANISTER_ID=$(dfx canister id aiChatbot --network $NETWORK)
print_success "aiChatbot deployed: $AI_CANISTER_ID"

# Deploy frontend if not skipped
if [[ "$SKIP_FRONTEND" == false ]]; then
    print_status "Building frontend..."
    cd Frontend
    
    cd ..
    
    print_status "Deploying frontend..."
    dfx deploy deresnet_frontend --network $NETWORK
    FRONTEND_CANISTER_ID=$(dfx canister id deresnet_frontend --network $NETWORK)
    print_success "Frontend deployed: $FRONTEND_CANISTER_ID"
fi

# Generate Candid interfaces
print_status "Generating Candid interfaces..."
dfx generate --network $NETWORK

# Initialize system with test data
print_status "Initializing system with test data..."

# Initialize tokens for the deployer
dfx canister call daoSystem initializeTokens --network $NETWORK

# Create a test user
dfx canister call paperStorage registerUser "(record {
    name = \"Dr. Test User\";
    email = \"test@deresnet.org\";
    institution = \"DeResNet Foundation\";
    avatar = null;
})" --network $NETWORK 2>/dev/null || print_warning "User might already be registered"

# Create a test proposal
dfx canister call daoSystem createProposal "(record {
    title = \"Initial Platform Development Grant\";
    description = \"Proposal to allocate resources for continued platform development and community growth.\";
    proposalType = variant { grant };
    requiredTokens = 100;
    duration = 604800000000000; // 7 days in nanoseconds
})" --network $NETWORK 2>/dev/null || print_warning "Test proposal creation might have failed"

print_success "Test data initialized"

# Display deployment information
echo ""
echo "🎉 DeResNet deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "===================="
echo "Network: $NETWORK"
echo "paperStorage: $PAPER_CANISTER_ID"
echo "daoSystem: $DAO_CANISTER_ID" 
echo "aiChatbot: $AI_CANISTER_ID"

if [[ "$SKIP_FRONTEND" == false ]]; then
    echo "frontend: $FRONTEND_CANISTER_ID"
    
    if [[ "$NETWORK" == "local" ]]; then
        echo ""
        echo "🌐 Access your application:"
        echo "Frontend: http://localhost:4943/?canisterId=$FRONTEND_CANISTER_ID"
        echo "Candid UI: http://localhost:4943/?canisterId=$(dfx canister id __Candid_UI --network $NETWORK)"
    fi
fi

echo ""
echo "🔧 Useful commands:"
echo "dfx canister call paperStorage --help"
echo "dfx canister call daoSystem --help"
echo "dfx canister call aiChatbot --help"
echo ""

if [[ "$NETWORK" == "local" ]]; then
    echo "💡 To stop the local replica: dfx stop"
fi

print_success "Deployment completed! 🚀"