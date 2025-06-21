#!/bin/bash

# DeResNet Development Setup Script
# This script sets up the complete development environment for DeResNet

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECKMARK="✅"
CROSSMARK="❌"
ARROW="➡️"
GEAR="⚙️"
ROCKET="🚀"
BOOK="📚"

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    DeResNet Setup Script                     ║"
    echo "║          Decentralized Academic Research Platform            ║"
    echo "║                   Powered by Internet Computer               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${CYAN}${ARROW} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSSMARK} $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Node.js version
check_node_version() {
    if command_exists node; then
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 16 ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Function to install Node.js via NVM
install_nodejs() {
    print_status "Installing Node.js via NVM..."
    
    if ! command_exists nvm; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
    
    nvm install 18
    nvm use 18
    nvm alias default 18
    print_success "Node.js 18 installed and set as default"
}

# Function to install DFX
install_dfx() {
    print_status "Installing DFINITY SDK (DFX)..."
    
    if command_exists dfx; then
        print_info "DFX is already installed: $(dfx --version)"
        return
    fi
    
    sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
    
    # Add dfx to PATH if not already there
    if ! command_exists dfx; then
        export PATH="$HOME/bin:$PATH"
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    fi
    
    print_success "DFX installed successfully: $(dfx --version)"
}

# Function to setup DFX identity
setup_dfx_identity() {
    print_status "Setting up DFX identity..."
    
    # Create development identity if it doesn't exist
    if ! dfx identity list | grep -q "deresnet-dev"; then
        dfx identity new deresnet-dev --storage-mode plaintext
        print_success "Created deresnet-dev identity"
    else
        print_info "deresnet-dev identity already exists"
    fi
    
    dfx identity use deresnet-dev
    print_success "Using identity: $(dfx identity whoami)"
    print_info "Principal: $(dfx identity get-principal)"
}

# Function to install project dependencies
install_dependencies() {
    print_status "Installing project dependencies..."
    
    # Install root dependencies
    print_status "Installing root package dependencies..."
    npm install
    
    # Install frontend dependencies
    if [ -d "deresnet-frontend" ]; then
        print_status "Installing frontend dependencies..."
        cd deresnet-frontend
        npm install
        cd ..
    else
        print_warning "Frontend directory not found, skipping frontend dependencies"
    fi
    
    print_success "All dependencies installed"
}

# Function to check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    local all_good=true
    
    # Check operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_success "Operating System: Linux ✓"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_success "Operating System: macOS ✓"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        print_warning "Operating System: Windows (WSL recommended)"
    else
        print_error "Unsupported operating system: $OSTYPE"
        all_good=false
    fi
    
    # Check curl
    if command_exists curl; then
        print_success "curl: Available ✓"
    else
        print_error "curl: Not found (required for installation)"
        all_good=false
    fi
    
    # Check git
    if command_exists git; then
        print_success "git: Available ✓"
    else
        print_error "git: Not found (required for development)"
        all_good=false
    fi
    
    # Check Node.js
    if check_node_version; then
        print_success "Node.js: $(node --version) ✓"
    else
        print_warning "Node.js: Not found or version < 16"
        all_good=false
    fi
    
    # Check npm
    if command_exists npm; then
        print_success "npm: $(npm --version) ✓"
    else
        print_warning "npm: Not found"
        all_good=false
    fi
    
    if [ "$all_good" = false ]; then
        print_error "Some requirements are missing. The script will attempt to install them."
    fi
}

# Function to setup VS Code extensions (optional)
setup_vscode() {
    if command_exists code; then
        print_status "Setting up VS Code extensions..."
        
        # Recommended extensions for DeResNet development
        local extensions=(
            "ms-vscode.vscode-typescript-next"
            "bradlc.vscode-tailwindcss"
            "esbenp.prettier-vscode"
            "ms-vscode.vscode-eslint"
            "ms-vscode.vscode-json"
            "redhat.vscode-yaml"
            "ms-vscode.vscode-markdown"
        )
        
        for ext in "${extensions[@]}"; do
            if code --list-extensions | grep -q "$ext"; then
                print_info "Extension $ext already installed"
            else
                print_status "Installing VS Code extension: $ext"
                code --install-extension "$ext" --force
            fi
        done
        
        print_success "VS Code extensions setup complete"
    else
        print_info "VS Code not found, skipping extension setup"
    fi
}

# Function to create environment files
create_env_files() {
    print_status "Creating environment configuration files..."
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        cat > .env << EOF
# DeResNet Environment Configuration
DFX_NETWORK=local
NODE_ENV=development

# Canister IDs (will be populated after deployment)
CANISTER_ID_PAPERSTORAGE=
CANISTER_ID_DAOSYSTEM=
CANISTER_ID_AICHATBOT=
CANISTER_ID_FRONTEND=

# Frontend Configuration
REACT_APP_IC_HOST=http://localhost:4943
REACT_APP_ENVIRONMENT=development
REACT_APP_ENABLE_LOGGER=true

# Development Settings
ENABLE_HOT_RELOAD=true
SKIP_PREFLIGHT_CHECK=true
EOF
        print_success "Created .env file"
    else
        print_info ".env file already exists"
    fi
    
    # Create frontend .env file if frontend exists
    if [ -d "deresnet-frontend" ] && [ ! -f "deresnet-frontend/.env.local" ]; then
        cat > deresnet-frontend/.env.local << EOF
# DeResNet Frontend Environment
NEXT_PUBLIC_IC_HOST=http://localhost:4943
NEXT_PUBLIC_ENVIRONMENT=development
NEXT_PUBLIC_ENABLE_LOGGER=true
EOF
        print_success "Created frontend .env.local file"
    fi
}

# Function to setup git hooks (optional)
setup_git_hooks() {
    if [ -d ".git" ]; then
        print_status "Setting up git hooks..."
        
        # Create pre-commit hook
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# DeResNet pre-commit hook

echo "Running pre-commit checks..."

# Run linting
if [ -d "deresnet-frontend" ]; then
    cd deresnet-frontend
    npm run lint
    if [ $? -ne 0 ]; then
        echo "Linting failed. Please fix the issues before committing."
        exit 1
    fi
    cd ..
fi

echo "Pre-commit checks passed ✅"
EOF
        
        chmod +x .git/hooks/pre-commit
        print_success "Git pre-commit hook installed"
    else
        print_info "Not a git repository, skipping git hooks setup"
    fi
}

# Function to run initial tests
run_initial_tests() {
    print_status "Running initial verification tests..."
    
    # Start DFX in background
    print_status "Starting local DFX replica..."
    dfx start --background --clean
    
    # Wait for replica to be ready
    sleep 5
    
    # Deploy canisters
    print_status "Deploying canisters for testing..."
    dfx deploy
    
    # Run a simple test
    print_status "Running connectivity test..."
    if dfx canister call paperStorage getPaperStats; then
        print_success "Canister connectivity test passed"
    else
        print_warning "Canister connectivity test failed (this might be expected for fresh deployment)"
    fi
    
    # Stop DFX
    dfx stop
    print_success "Initial tests completed"
}

# Function to display next steps
show_next_steps() {
    echo ""
    print_success "🎉 DeResNet setup completed successfully!"
    echo ""
    echo -e "${PURPLE}${BOOK} Next Steps:${NC}"
    echo "=================="
    echo ""
    echo "1. Start development environment:"
    echo "   ${CYAN}make dev${NC}"
    echo ""
    echo "2. Or run commands individually:"
    echo "   ${CYAN}dfx start --background${NC}    # Start local replica"
    echo "   ${CYAN}dfx deploy${NC}                # Deploy canisters"
    echo "   ${CYAN}make init-data${NC}            # Initialize with test data"
    echo ""
    echo "3. Run tests:"
    echo "   ${CYAN}make test${NC}                 # Run all tests"
    echo ""
    echo "4. Access the application:"
    echo "   ${CYAN}Frontend: http://localhost:4943/?canisterId=<frontend-canister-id>${NC}"
    echo "   ${CYAN}Candid UI: http://localhost:4943/?canisterId=<candid-ui-canister-id>${NC}"
    echo ""
    echo "5. Useful commands:"
    echo "   ${CYAN}make help${NC}                 # Show all available commands"
    echo "   ${CYAN}make status${NC}               # Check canister status"
    echo "   ${CYAN}make info${NC}                 # Show deployment info"
    echo ""
    echo -e "${GREEN}${ROCKET} Happy coding!${NC}"
    echo ""
    echo -e "${BLUE}💡 Tips:${NC}"
    echo "- Use 'make help' to see all available commands"
    echo "- Check the README.md for detailed documentation"
    echo "- Join our Discord for community support"
    echo ""
}

# Main setup function
main() {
    print_header
    
    echo -e "${YELLOW}This script will set up your DeResNet development environment.${NC}"
    echo -e "${YELLOW}It will install required dependencies and configure the project.${NC}"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to continue? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Setup cancelled by user"
        exit 0
    fi
    
    print_status "Starting DeResNet development environment setup..."
    echo ""
    
    # Check requirements
    check_requirements
    echo ""
    
    # Install Node.js if needed
    if ! check_node_version; then
        install_nodejs
        echo ""
    fi
    
    # Install DFX
    install_dfx
    echo ""
    
    # Setup DFX identity
    setup_dfx_identity
    echo ""
    
    # Install dependencies
    install_dependencies
    echo ""
    
    # Create environment files
    create_env_files
    echo ""
    
    # Setup VS Code (optional)
    echo -e "${YELLOW}Do you want to set up VS Code extensions? [y/N]${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_vscode
        echo ""
    fi
    
    # Setup git hooks (optional)
    echo -e "${YELLOW}Do you want to set up git hooks for code quality? [y/N]${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_git_hooks
        echo ""
    fi
    
    # Run initial tests (optional)
    echo -e "${YELLOW}Do you want to run initial verification tests? [y/N]${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_initial_tests
        echo ""
    fi
    
    # Show next steps
    show_next_steps
}

# Handle script arguments
case "$1" in
    --help|-h)
        echo "DeResNet Setup Script"
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --minimal      Skip optional setup steps"
        echo "  --auto         Run with default options (non-interactive)"
        echo ""
        exit 0
        ;;
    --minimal)
        print_header
        check_requirements
        install_dfx
        setup_dfx_identity
        install_dependencies
        create_env_files
        print_success "Minimal setup completed"
        ;;
    --auto)
        print_header
        check_requirements
        if ! check_node_version; then
            install_nodejs
        fi
        install_dfx
        setup_dfx_identity
        install_dependencies
        create_env_files
        setup_vscode
        setup_git_hooks
        print_success "Automated setup completed"
        show_next_steps
        ;;
    *)
        main
        ;;
esac