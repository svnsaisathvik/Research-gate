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

import Prim "mo:prim";

import Types "../shared/Types";

actor AIChatbot {
    
    type ChatMessage = Types.ChatMessage;
    type ChatSession = Types.ChatSession;
    type Paper = Types.Paper;
    type Error = Types.Error;
    type Result<T, E> = Types.Result<T, E>;
    type PaginatedResult<T> = Types.PaginatedResult<T>;
    type PaginationParams = Types.PaginationParams;

    // Stable storage
    private stable var sessionsEntries : [(Text, ChatSession)] = [];
    private stable var messagesEntries : [(Text, ChatMessage)] = [];
    private stable var sessionCounter : Nat = 0;
    private stable var messageCounter : Nat = 0;

    // Runtime storage
    private var sessions = Map.HashMap<Text, ChatSession>(0, Text.equal, Text.hash);
    private var messages = Map.HashMap<Text, ChatMessage>(0, Text.equal, Text.hash);
    private var userSessions = Map.HashMap<Principal, [Text]>(0, Principal.equal, Principal.hash);

    // Paper analysis cache
    private var paperSummaries = Map.HashMap<Text, Text>(0, Text.equal, Text.hash);
    private var paperKeywords = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);
    private var similarPapers = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);

    // Initialize from stable storage
    system func preupgrade() {
        sessionsEntries := Iter.toArray(sessions.entries());
        messagesEntries := Iter.toArray(messages.entries());
    };

    system func postupgrade() {
        sessions := Map.fromIter<Text, ChatSession>(sessionsEntries.vals(), sessionsEntries.size(), Text.equal, Text.hash);
        messages := Map.fromIter<Text, ChatMessage>(messagesEntries.vals(), messagesEntries.size(), Text.equal, Text.hash);
        sessionsEntries := [];
        messagesEntries := [];
        rebuildUserSessions();
    };

    // Private functions
    private func generateSessionId() : Text {
        sessionCounter += 1;
        "session_" # Nat.toText(sessionCounter)
    };

    private func generateMessageId() : Text {
        messageCounter += 1;
        "msg_" # Nat.toText(messageCounter)
    };

    private func rebuildUserSessions() {
        for ((sessionId, session) in sessions.entries()) {
            switch (userSessions.get(session.userId)) {
                case null { 
                    userSessions.put(session.userId, [sessionId]); 
                };
                case (?existing) { 
                    let updated = Array.append(existing, [sessionId]);
                    userSessions.put(session.userId, updated);
                };
            };
        };
    };

    private func addMessageToSession(sessionId: Text, message: ChatMessage) : Bool {
        switch (sessions.get(sessionId)) {
            case null false;
            case (?session) {
                let updatedMessages = Array.append(session.messages, [message]);
                let updatedSession = {
                    session with
                    messages = updatedMessages;
                    lastActivity = Time.now();
                };
                sessions.put(sessionId, updatedSession);
                messages.put(message.id, message);
                true
            };
        };
    };

    private func analyzeUserInput(input: Text) : {intent: Text; entities: [Text]; confidence: Float} {
        let inputLower = Text.map(input, Prim.charToLower);
        
        // Simple intent classification
        let intent = if (Text.contains(inputLower, #text "summarize") or Text.contains(inputLower, #text "summary")) {
            "summarize"
        } else if (Text.contains(inputLower, #text "find") or Text.contains(inputLower, #text "search") or Text.contains(inputLower, #text "similar")) {
            "search"
        } else if (Text.contains(inputLower, #text "explain") or Text.contains(inputLower, #text "what is") or Text.contains(inputLower, #text "how does")) {
            "explain"
        } else if (Text.contains(inputLower, #text "trend") or Text.contains(inputLower, #text "latest") or Text.contains(inputLower, #text "recent")) {
            "trends"
        } else {
            "general"
        };

        // Extract entities (simplified)
        let entities = extractEntities(inputLower);
        
        {
            intent = intent;
            entities = entities;
            confidence = 0.8; // Simplified confidence score
        }
    };

    private func extractEntities(text: Text) : [Text] {
        let buffer = Buffer.Buffer<Text>(0);
        
        // Common research topics and terms
        let researchTerms = [
            "quantum", "machine learning", "blockchain", "climate", "ai", "neural network",
            "algorithm", "cryptography", "biology", "physics", "chemistry", "mathematics",
            "computer science", "engineering", "medicine", "economics", "psychology"
        ];

        for (term in researchTerms.vals()) {
            if (Text.contains(text, #text term)) {
                buffer.add(term);
            };
        };

        Buffer.toArray(buffer)
    };

    private func generateAIResponse(userInput: Text, entities: [Text], intent: Text, paperRef: ?Text) : Text {
        switch (intent) {
            case ("summarize") {
                generateSummaryResponse(entities, paperRef)
            };
            case ("search") {
                generateSearchResponse(entities)
            };
            case ("explain") {
                generateExplanationResponse(entities)
            };
            case ("trends") {
                generateTrendsResponse(entities)
            };
            case _ {
                generateGeneralResponse(userInput, entities)
            };
        };
    };

    private func generateSummaryResponse(entities: [Text], paperRef: ?Text) : Text {
        switch (paperRef) {
            case (?paperId) {
                switch (paperSummaries.get(paperId)) {
                    case (?summary) { summary };
                    case null {
                        "I don't have a summary for that paper yet. Let me analyze it and provide insights based on the available information."
                    };
                };
            };
            case null {
                if (entities.size() > 0) {
                    let topic = entities[0];
                    "Here's what I know about " # topic # ":\n\n" #
                    "Based on recent research in DeResNet, " # topic # " is an active area of investigation. " #
                    "Key developments include methodological advances, practical applications, and theoretical breakthroughs. " #
                    "Would you like me to find specific papers on this topic?"
                } else {
                    "I'd be happy to summarize research for you! Please specify which paper or topic you'd like me to summarize."
                };
            };
        };
    };

    private func generateSearchResponse(entities: [Text]) : Text {
        if (entities.size() > 0) {
            let topic = entities[0];
            "I found several interesting papers related to " # topic # ":\n\n" #
            "• Recent advances in " # topic # " methodologies\n" #
            "• Applications of " # topic # " in various domains\n" #
            "• Comparative studies and benchmarks\n\n" #
            "Would you like me to provide more details about any of these areas?"
        } else {
            "I can help you find papers on any research topic. What specific area are you interested in exploring?"
        };
    };

    private func generateExplanationResponse(entities: [Text]) : Text {
        if (entities.size() > 0) {
            let concept = entities[0];
            switch (concept) {
                case ("quantum") {
                    "Quantum computing leverages quantum mechanical phenomena like superposition and entanglement to process information. " #
                    "Unlike classical bits that are either 0 or 1, quantum bits (qubits) can exist in multiple states simultaneously, " #
                    "potentially enabling exponential computational advantages for certain problems."
                };
                case ("machine learning") {
                    "Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience " #
                    "without being explicitly programmed. It involves algorithms that can identify patterns in data and make predictions " #
                    "or decisions based on those patterns."
                };
                case ("blockchain") {
                    "Blockchain is a distributed ledger technology that maintains a continuously growing list of records, called blocks, " #
                    "which are linked and secured using cryptography. Each block contains a cryptographic hash of the previous block, " #
                    "a timestamp, and transaction data."
                };
                case _ {
                    "I can explain various concepts in " # concept # ". Could you be more specific about what aspect you'd like me to explain?"
                };
            };
        } else {
            "I'd be happy to explain any research concept or methodology. What would you like to learn about?"
        };
    };

    private func generateTrendsResponse(_: [Text]) : Text {
        "**Current Research Trends in DeResNet:**\n\n" #
        "🔥 **Hot Topics:**\n" #
        "• Quantum-classical hybrid algorithms\n" #
        "• Sustainable AI and green computing\n" #
        "• Decentralized research collaboration\n" #
        "• AI-powered peer review systems\n\n" #
        "📈 **Emerging Areas:**\n" #
        "• Cross-disciplinary research methodologies\n" #
        "• Blockchain-based research integrity\n" #
        "• Real-time collaborative research platforms\n\n" #
        "The research community is particularly focused on interdisciplinary approaches and technological sustainability."
    };

    private func generateGeneralResponse(userInput: Text, entities: [Text]) : Text {
        let responses = [
            "That's an interesting question! Based on the research available in DeResNet, I can help you explore various aspects of this topic.",
            "I understand you're looking for information about this. Let me provide some insights based on current research trends.",
            "Great question! The research community has been actively working on related topics. Here's what I can tell you:",
            "I can definitely help with that. Based on my analysis of recent papers, here are some key insights:"
        ];
        
        // Simple response selection (in a real implementation, this would be more sophisticated)
        let responseIndex = (userInput.size() + entities.size()) % responses.size();
        responses[responseIndex] # "\n\n" #
        "Would you like me to find specific papers or provide more detailed explanations on any particular aspect?"
    };

    // Public functions

    // Session management
    public shared(msg) func createChatSession() : async Result<Text, Error> {
        let sessionId = generateSessionId();
        let session : ChatSession = {
            id = sessionId;
            userId = msg.caller;
            messages = [];
            createdAt = Time.now();
            lastActivity = Time.now();
        };

        sessions.put(sessionId, session);

        // Update user sessions
        switch (userSessions.get(msg.caller)) {
            case null { 
                userSessions.put(msg.caller, [sessionId]); 
            };
            case (?existing) { 
                let updated = Array.append(existing, [sessionId]);
                userSessions.put(msg.caller, updated);
            };
        };

        #ok(sessionId)
    };

    public shared query(msg) func getChatSession(sessionId: Text) : async Result<ChatSession, Error> {
        switch (sessions.get(sessionId)) {
            case (?session) {
                if (Principal.equal(session.userId, msg.caller)) {
                    #ok(session)
                } else {
                    #err(#Unauthorized)
                }
            };
            case null { #err(#NotFound) };
        };
    };

    public shared query(msg) func getUserSessions() : async [ChatSession] {
        switch (userSessions.get(msg.caller)) {
            case null { [] };
            case (?sessionIds) {
                let buffer = Buffer.Buffer<ChatSession>(sessionIds.size());
                for (sessionId in sessionIds.vals()) {
                    switch (sessions.get(sessionId)) {
                        case (?session) { buffer.add(session) };
                        case null {};
                    };
                };
                Buffer.toArray(buffer)
            };
        };
    };

    // Message handling
    public shared(msg) func sendMessage(sessionId: Text, content: Text, paperRef: ?Text) : async Result<ChatMessage, Error> {
        switch (sessions.get(sessionId)) {
            case null { #err(#NotFound) };
            case (?session) {
                if (not Principal.equal(session.userId, msg.caller)) {
                    return #err(#Unauthorized);
                };

                // Create user message
                let userMessageId = generateMessageId();
                let userMessage : ChatMessage = {
                    id = userMessageId;
                    messageType = #user;
                    content = content;
                    timestamp = Time.now();
                    userId = msg.caller;
                    paperRef = paperRef;
                };

                // Add user message to session
                if (not addMessageToSession(sessionId, userMessage)) {
                    return #err(#InvalidInput("Failed to add message to session"));
                };

                // Analyze user input and generate AI response
                let analysis = analyzeUserInput(content);
                let aiResponseContent = generateAIResponse(content, analysis.entities, analysis.intent, paperRef);

                // Create AI response message
                let aiMessageId = generateMessageId();
                let aiMessage : ChatMessage = {
                    id = aiMessageId;
                    messageType = #ai;
                    content = aiResponseContent;
                    timestamp = Time.now();
                    userId = Principal.fromText("2vxsx-fae"); // System principal
                    paperRef = paperRef;
                };

                // Add AI message to session
                if (not addMessageToSession(sessionId, aiMessage)) {
                    return #err(#InvalidInput("Failed to add AI response to session"));
                };

                #ok(aiMessage)
            };
        };
    };

    // Paper analysis
    public shared func analyzePaper(paperId: Text, paperContent: Text) : async Result<Text, Error> {
        // Simulate paper analysis (in a real implementation, this would use NLP models)
        let summary = generatePaperSummary(paperId, paperContent);
        paperSummaries.put(paperId, summary);
        
        let keywords = extractPaperKeywords(paperContent);
        paperKeywords.put(paperId, keywords);
        
        #ok(summary)
    };

    private func generatePaperSummary(paperId: Text, _: Text) : Text {
        // Simplified paper summarization
        "**Paper Summary for " # paperId # ":**\n\n" #
        "This research paper presents novel contributions to its field through innovative methodologies and comprehensive analysis. " #
        "The work addresses important challenges and provides valuable insights that advance our understanding of the subject matter.\n\n" #
        "**Key Contributions:**\n" #
        "• Novel approach to problem solving\n" #
        "• Comprehensive experimental validation\n" #
        "• Significant improvements over existing methods\n" #
        "• Clear implications for future research\n\n" #
        "**Methodology:**\n" #
        "The authors employ rigorous experimental design and statistical analysis to support their findings. " #
        "The approach is well-documented and reproducible.\n\n" #
        "**Impact:**\n" #
        "This work has the potential to influence future research directions and practical applications in the field."
    };

    private func extractPaperKeywords(_: Text) : [Text] {
        // Simplified keyword extraction
        ["research", "methodology", "analysis", "results", "conclusions", "innovation"]
    };

    public shared query func getPaperSummary(paperId: Text) : async Result<Text, Error> {
        switch (paperSummaries.get(paperId)) {
            case (?summary) { #ok(summary) };
            case null { #err(#NotFound) };
        };
    };

    public shared query func getPaperKeywords(paperId: Text) : async Result<[Text], Error> {
        switch (paperKeywords.get(paperId)) {
            case (?keywords) { #ok(keywords) };
            case null { #err(#NotFound) };
        };
    };

    // Similar papers recommendation
    public shared func findSimilarPapers(paperId: Text) : async Result<[Text], Error> {
        // Simulate similarity calculation
        let similar = ["paper_1", "paper_2", "paper_3"]; // This would be calculated based on content similarity
        similarPapers.put(paperId, similar);
        #ok(similar)
    };

    public shared query func getSimilarPapers(paperId: Text) : async Result<[Text], Error> {
        switch (similarPapers.get(paperId)) {
            case (?similar) { #ok(similar) };
            case null { #err(#NotFound) };
        };
    };

    // Research insights
    public shared query func getResearchInsights(topic: Text) : async Text {
        "**Research Insights for '" # topic # "':**\n\n" #
        "Based on analysis of papers in DeResNet, here are key insights about " # topic # ":\n\n" #
        "📊 **Current State:**\n" #
        "• Active research area with growing interest\n" #
        "• Multiple approaches being explored\n" #
        "• Strong interdisciplinary connections\n\n" #
        "🔬 **Research Gaps:**\n" #
        "• Need for standardized evaluation metrics\n" #
        "• Limited long-term studies\n" #
        "• Opportunities for cross-domain applications\n\n" #
        "🚀 **Future Directions:**\n" #
        "• Integration with emerging technologies\n" #
        "• Scalability and efficiency improvements\n" #
        "• Real-world deployment considerations\n\n" #
        "Would you like me to elaborate on any of these aspects?"
    };

    // Statistics
    public shared query func getChatStats() : async {
        totalSessions: Nat;
        totalMessages: Nat;
        averageMessagesPerSession: Float;
        papersAnalyzed: Nat;
    } {
        let totalSessions = sessions.size();
        let totalMessages = messages.size();
        let averageMessages = if (totalSessions > 0) { 
            Float.fromInt(totalMessages) / Float.fromInt(totalSessions) 
        } else { 
            0.0 
        };

        {
            totalSessions = totalSessions;
            totalMessages = totalMessages;
            averageMessagesPerSession = averageMessages;
            papersAnalyzed = paperSummaries.size();
        }
    };

    // Utility functions
    public shared func deleteChatSession(sessionId: Text) : async Result<(), Error> {
        switch (sessions.get(sessionId)) {
            case null { #err(#NotFound) };
            case (?session) {
                sessions.delete(sessionId);
                
                // Remove from user sessions
                switch (userSessions.get(session.userId)) {
                    case null {};
                    case (?userSessionsList) {
                        let filtered = Array.filter<Text>(userSessionsList, func(id) { not Text.equal(id, sessionId) });
                        userSessions.put(session.userId, filtered);
                    };
                };
                
                #ok(())
            };
        };
    };

    public shared func clearOldSessions(maxAge: Int) : async Nat {
        let currentTime = Time.now();
        let cutoff = currentTime - maxAge;
        var deletedCount = 0;

        let sessionsToDelete = Buffer.Buffer<Text>(0);
        
        for ((id, session) in sessions.entries()) {
            if (session.lastActivity < cutoff) {
                sessionsToDelete.add(id);
            };
        };

        for (sessionId in sessionsToDelete.vals()) {
            switch (await deleteChatSession(sessionId)) {
                case (#ok()) { deletedCount += 1 };
                case (#err(_)) {};
            };
        };

        deletedCount
    };
}