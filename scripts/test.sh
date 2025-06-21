#!/bin/bash

# DeResNet Test Script
# This script runs comprehensive tests for all canisters

set -e

echo "🧪 Starting DeResNet test suite..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

test_counter=0
passed_tests=0
failed_tests=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    test_counter=$((test_counter + 1))
    print_status "Running test $test_counter: $test_name"
    
    if eval "$test_command"; then
        print_success "$test_name"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        print_error "$test_name"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

# Ensure dfx is running
print_status "Ensuring dfx replica is running..."
dfx ping || (dfx start --background && sleep 5)

# Test PaperStorage Canister
echo ""
echo "📄 Testing PaperStorage Canister"
echo "================================="

run_test "Register user" \
"dfx canister call paperStorage registerUser '(record {
    name = \"Dr. Alice Johnson\";
    email = \"alice@university.edu\";
    institution = \"MIT\";
    avatar = null;
})' --output json | grep -q '\"ok\"'"

run_test "Get user profile" \
"dfx canister call paperStorage getUser --output json | grep -q '\"ok\"'"

run_test "Submit paper" \
"dfx canister call paperStorage submitPaper '(record {
    title = \"Test Paper on Quantum Computing\";
    abstract = \"This is a test abstract for quantum computing research.\";
    authors = vec { \"Dr. Alice Johnson\"; \"Prof. Bob Smith\" };
    institution = \"MIT\";
    tags = vec { \"quantum\"; \"computing\"; \"algorithms\" };
    doi = opt \"10.1000/test.123\";
    fileData = blob \"test file content\";
    category = \"computer-science\";
})' --output json | grep -q '\"ok\"'"

run_test "Get all papers" \
"dfx canister call paperStorage getAllPapers '(record { page = 0; limit = 10 })' --output json | grep -q '\"data\"'"

run_test "Get paper stats" \
"dfx canister call paperStorage getPaperStats --output json | grep -q 'totalPapers'"

run_test "Submit review" \
"dfx canister call paperStorage submitReview '(\"paper_1\", 8, \"Great paper with solid methodology.\", true)' --output json | grep -q '\"ok\"'"

# Test DAOSystem Canister
echo ""
echo "🗳️  Testing DAOSystem Canister"
echo "=============================="

run_test "Initialize tokens" \
"dfx canister call daoSystem initializeTokens --output json | grep -q '\"ok\"'"

run_test "Get token balance" \
"dfx canister call daoSystem getTokenBalance --output json | grep -E '[0-9]+'"

run_test "Create proposal" \
"dfx canister call daoSystem createProposal '(record {
    title = \"Test Research Grant\";
    description = \"A test proposal for research funding.\";
    proposalType = variant { grant };
    requiredTokens = 100;
    duration = 604800000000000;
})' --output json | grep -q '\"ok\"'"

run_test "Get all proposals" \
"dfx canister call daoSystem getAllProposals '(record { page = 0; limit = 10 })' --output json | grep -q '\"data\"'"

run_test "Vote on proposal" \
"dfx canister call daoSystem vote '(\"proposal_1\", true)' --output json | grep -q '\"ok\"'"

run_test "Get DAO stats" \
"dfx canister call daoSystem getDAOStats --output json | grep -q 'totalProposals'"

run_test "Transfer tokens" \
"dfx canister call daoSystem transferTokens '(principal \"rdmx6-jaaaa-aaaaa-aaadq-cai\", 100)' --output json | grep -q '\"ok\"'"

# Test AIChatbot Canister
echo ""
echo "🤖 Testing AIChatbot Canister"
echo "============================="

run_test "Create chat session" \
"dfx canister call aiChatbot createChatSession --output json | grep -q '\"ok\"'"

run_test "Send message" \
"dfx canister call aiChatbot sendMessage '(\"session_1\", \"What are the latest trends in quantum computing?\", null)' --output json | grep -q '\"ok\"'"

run_test "Get user sessions" \
"dfx canister call aiChatbot getUserSessions --output json | grep -q '\[\]'"

run_test "Get research insights" \
"dfx canister call aiChatbot getResearchInsights '(\"quantum computing\")' --output json | grep -q 'Research Insights'"

run_test "Analyze paper" \
"dfx canister call aiChatbot analyzePaper '(\"paper_1\", \"This is test paper content about quantum computing algorithms.\")' --output json | grep -q '\"ok\"'"

run_test "Get paper summary" \
"dfx canister call aiChatbot getPaperSummary '(\"paper_1\")' --output json | grep -q '\"ok\"'"

run_test "Find similar papers" \
"dfx canister call aiChatbot findSimilarPapers '(\"paper_1\")' --output json | grep -q '\"ok\"'"

run_test "Get chat stats" \
"dfx canister call aiChatbot getChatStats --output json | grep -q 'totalSessions'"

# Integration Tests
echo ""
echo "🔗 Running Integration Tests"
echo "============================"

run_test "Cross-canister workflow: Submit paper and analyze with AI" \
"dfx canister call paperStorage submitPaper '(record {
    title = \"AI in Climate Research\";
    abstract = \"This paper explores AI applications in climate science.\";
    authors = vec { \"Dr. Climate Researcher\" };
    institution = \"Climate University\";
    tags = vec { \"ai\"; \"climate\"; \"machine-learning\" };
    doi = null;
    fileData = blob \"climate ai research content\";
    category = \"environmental-science\";
})' --output json | grep -q '\"ok\"' && \
dfx canister call aiChatbot analyzePaper '(\"paper_2\", \"AI applications in climate science research.\")' --output json | grep -q '\"ok\"'"

run_test "DAO proposal for paper funding" \
"dfx canister call daoSystem createProposal '(record {
    title = \"Fund Climate AI Research\";
    description = \"Proposal to fund the climate AI research paper.\";
    proposalType = variant { grant };
    requiredTokens = 50;
    duration = 604800000000000;
})' --output json | grep -q '\"ok\"'"

# Performance Tests
echo ""
echo "⚡ Running Performance Tests"
echo "==========================="

run_test "Bulk paper submission (5 papers)" \
"for i in {1..5}; do
    dfx canister call paperStorage submitPaper \"(record {
        title = \\\"Performance Test Paper \$i\\\";
        abstract = \\\"This is performance test paper number \$i\\\";
        authors = vec { \\\"Test Author \$i\\\" };
        institution = \\\"Test University\\\";
        tags = vec { \\\"performance\\\"; \\\"test\\\" };
        doi = null;
        fileData = blob \\\"test content \$i\\\";
        category = \\\"computer-science\\\";
    })\" > /dev/null 2>&1 || exit 1;
done"

run_test "Bulk proposal creation (3 proposals)" \
"for i in {1..3}; do
    dfx canister call daoSystem createProposal \"(record {
        title = \\\"Performance Test Proposal \$i\\\";
        description = \\\"This is performance test proposal number \$i\\\";
        proposalType = variant { governance };
        requiredTokens = 25;
        duration = 604800000000000;
    })\" > /dev/null 2>&1 || exit 1;
done"

# Error Handling Tests
echo ""
echo "❌ Testing Error Handling"
echo "========================="

run_test "Invalid paper submission (missing title)" \
"dfx canister call paperStorage submitPaper '(record {
    title = \"\";
    abstract = \"Test abstract\";
    authors = vec { \"Test Author\" };
    institution = \"Test University\";
    tags = vec { \"test\" };
    doi = null;
    fileData = blob \"test\";
    category = \"test\";
})' --output json 2>&1 | grep -q 'err' || exit 1"

run_test "Vote on non-existent proposal" \
"dfx canister call daoSystem vote '(\"nonexistent_proposal\", true)' --output json 2>&1 | grep -q 'err' || exit 1"

run_test "Get non-existent chat session" \
"dfx canister call aiChatbot getChatSession '(\"nonexistent_session\")' --output json 2>&1 | grep -q 'err' || exit 1"

# Test Summary
echo ""
echo "📊 Test Summary"
echo "==============="
echo "Total tests run: $test_counter"
echo "Passed: $passed_tests"
echo "Failed: $failed_tests"

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ $failed_tests test(s) failed${NC}"
    exit 1
fi