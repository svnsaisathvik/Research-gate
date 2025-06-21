import React, { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, FileText, Lightbulb, Search } from 'lucide-react';

interface Message {
  id: string;
  type: 'user' | 'ai';
  content: string;
  timestamp: Date;
  paperRef?: string;
}

const AIChat: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      type: 'ai',
      content: 'Hello! I\'m DeResNet\'s AI research assistant. I can help you understand research papers, find similar works, generate summaries, and answer questions about any academic content. What would you like to explore today?',
      timestamp: new Date()
    }
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const predefinedQuestions = [
    "Summarize the latest quantum computing papers",
    "Find papers related to machine learning in climate science",
    "Explain the methodology in paper #1",
    "What are the current trends in blockchain research?"
  ];

  const handleSendMessage = async () => {
    if (!inputMessage.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      content: inputMessage,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setIsTyping(true);

    // Simulate AI response
    setTimeout(() => {
      const aiResponse = generateAIResponse(inputMessage);
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'ai',
        content: aiResponse,
        timestamp: new Date()
      };
      
      setMessages(prev => [...prev, aiMessage]);
      setIsTyping(false);
    }, 1500);
  };

  const generateAIResponse = (userInput: string): string => {
    const lowerInput = userInput.toLowerCase();
    
    if (lowerInput.includes('quantum')) {
      return `Based on the latest quantum computing research in DeResNet, I found several interesting developments:

**Key Findings:**
• Quantum error correction improvements showing 15% better fidelity
• New quantum algorithms for optimization problems
• Progress in quantum-classical hybrid systems

**Notable Papers:**
• "Quantum Computing Applications in Cryptography" by Dr. Alice Johnson - This paper explores quantum threats to current cryptographic systems and proposes quantum-resistant solutions.

Would you like me to dive deeper into any specific aspect of quantum computing research?`;
    }
    
    if (lowerInput.includes('climate') || lowerInput.includes('machine learning')) {
      return `I've analyzed the machine learning applications in climate science research:

**Current Trends:**
• Deep learning models for weather prediction with 23% improved accuracy
• Satellite data analysis using computer vision
• Carbon footprint modeling with reinforcement learning

**Recommended Reading:**
• "Machine Learning Approaches to Climate Change Prediction" by Dr. Carol Williams et al. - Shows novel ML architectures achieving state-of-the-art results.

The research shows promising applications of transformer models in climate data analysis. Would you like specific recommendations for your research area?`;
    }

    if (lowerInput.includes('paper #1') || lowerInput.includes('methodology')) {
      return `**Paper Analysis: "Quantum Computing Applications in Cryptography"**

**Methodology Overview:**
1. **Literature Review:** Comprehensive analysis of 200+ quantum cryptography papers
2. **Theoretical Framework:** Mathematical modeling of quantum algorithms vs. classical security
3. **Experimental Design:** Simulation of quantum attacks on RSA and ECC systems
4. **Performance Metrics:** Security analysis using quantum complexity theory

**Key Innovation:** The paper introduces a novel quantum-resistant protocol that maintains computational efficiency while providing post-quantum security guarantees.

**Limitations:** The approach requires quantum hardware not widely available yet.

Would you like me to explain any specific technical aspect in more detail?`;
    }

    if (lowerInput.includes('blockchain')) {
      return `**Current Blockchain Research Trends in DeResNet:**

**Popular Research Areas:**
• **Scalability Solutions:** Layer 2 protocols and sharding mechanisms
• **Consensus Mechanisms:** Proof-of-Stake variations and energy efficiency
• **DeFi Applications:** Automated market makers and yield farming protocols
• **Supply Chain Integration:** Transparency and traceability improvements

**Emerging Topics:**
• Cross-chain interoperability protocols
• Zero-knowledge proof applications
• NFTs for academic credentials
• DAOs for research funding

The research community is particularly focused on sustainability and real-world applications. Would you like me to find specific papers in any of these areas?`;
    }

    // Default response
    return `I understand you're asking about "${userInput}". Let me help you with that.

Based on the current research in DeResNet, I can provide insights on various topics including:
• Paper analysis and summarization
• Research trend identification
• Methodology explanations
• Similar work recommendations

Could you be more specific about what aspect you'd like me to focus on? For example:
- Are you looking for papers on a specific topic?
- Do you need help understanding a particular concept?
- Would you like me to analyze a specific research paper?`;
  };

  const handleQuestionClick = (question: string) => {
    setInputMessage(question);
  };

  const formatTimestamp = (timestamp: Date) => {
    return timestamp.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  return (
    <div className="max-w-4xl mx-auto h-[calc(100vh-12rem)] flex flex-col">
      {/* Header */}
      <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-t-xl p-6">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full flex items-center justify-center">
            <Bot className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
              AI Research Assistant
            </h1>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Your intelligent research companion
            </p>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 bg-white dark:bg-gray-800 border-x border-gray-200 dark:border-gray-700 overflow-y-auto p-6">
        <div className="space-y-6">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex items-start space-x-3 ${
                message.type === 'user' ? 'flex-row-reverse space-x-reverse' : ''
              }`}
            >
              <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                message.type === 'user' 
                  ? 'bg-blue-600 text-white' 
                  : 'bg-gradient-to-r from-purple-600 to-blue-600 text-white'
              }`}>
                {message.type === 'user' ? (
                  <User className="w-5 h-5" />
                ) : (
                  <Bot className="w-5 h-5" />
                )}
              </div>
              
              <div className={`flex-1 max-w-3xl ${message.type === 'user' ? 'text-right' : ''}`}>
                <div className={`inline-block p-4 rounded-lg ${
                  message.type === 'user'
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'
                }`}>
                  <div className="whitespace-pre-wrap">{message.content}</div>
                </div>
                <div className={`text-xs text-gray-500 dark:text-gray-400 mt-1 ${
                  message.type === 'user' ? 'text-right' : 'text-left'
                }`}>
                  {formatTimestamp(message.timestamp)}
                </div>
              </div>
            </div>
          ))}

          {isTyping && (
            <div className="flex items-start space-x-3">
              <div className="w-8 h-8 bg-gradient-to-r from-purple-600 to-blue-600 rounded-full flex items-center justify-center">
                <Bot className="w-5 h-5 text-white" />
              </div>
              <div className="bg-gray-100 dark:bg-gray-700 rounded-lg p-4">
                <div className="flex space-x-1">
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                </div>
              </div>
            </div>
          )}
        </div>
        <div ref={messagesEndRef} />
      </div>

      {/* Quick Questions */}
      {messages.length === 1 && (
        <div className="bg-white dark:bg-gray-800 border-x border-gray-200 dark:border-gray-700 p-4">
          <p className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
            Try asking about:
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
            {predefinedQuestions.map((question, index) => (
              <button
                key={index}
                onClick={() => handleQuestionClick(question)}
                className="text-left p-3 text-sm bg-gray-50 dark:bg-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 rounded-lg transition-colors flex items-center space-x-2"
              >
                <Lightbulb className="w-4 h-4 text-yellow-500 flex-shrink-0" />
                <span className="text-gray-700 dark:text-gray-300">{question}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input */}
      <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-b-xl p-4">
        <div className="flex space-x-3">
          <input
            type="text"
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            placeholder="Ask about research papers, methodologies, or request summaries..."
            className="flex-1 px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-900 text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <button
            onClick={handleSendMessage}
            disabled={!inputMessage.trim() || isTyping}
            className="px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded-lg transition-colors flex items-center space-x-2"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default AIChat;