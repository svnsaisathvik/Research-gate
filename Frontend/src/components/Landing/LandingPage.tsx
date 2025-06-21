import React from 'react';
import { 
  ArrowRight, 
  Shield, 
  Globe, 
  Users, 
  FileText, 
  Vote, 
  MessageSquare, 
  Coins,
  CheckCircle,
  Star,
  TrendingUp,
  Zap
} from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { mockUser } from '../../data/mockData';

interface LandingPageProps {
  onGetStarted: () => void;
}

const LandingPage: React.FC<LandingPageProps> = ({ onGetStarted }) => {
  const { login } = useAuth();

  const handleGetStarted = () => {
    login(mockUser);
    onGetStarted();
  };

  const features = [
    {
      icon: FileText,
      title: 'Decentralized Publishing',
      description: 'Publish research papers directly on-chain with immutable storage and transparent peer review.',
      color: 'text-blue-600 dark:text-blue-400'
    },
    {
      icon: Vote,
      title: 'DAO Governance',
      description: 'Participate in research funding decisions and platform governance through democratic voting.',
      color: 'text-purple-600 dark:text-purple-400'
    },
    {
      icon: MessageSquare,
      title: 'AI Research Assistant',
      description: 'Get instant paper summaries, research insights, and discover related work with our AI companion.',
      color: 'text-green-600 dark:text-green-400'
    },
    {
      icon: Coins,
      title: 'Multi-Chain Bridge',
      description: 'Seamlessly bridge tokens from Ethereum, Bitcoin, and other chains to participate in the ecosystem.',
      color: 'text-orange-600 dark:text-orange-400'
    },
    {
      icon: Shield,
      title: 'Secure & Transparent',
      description: 'Built on Internet Computer Protocol ensuring security, transparency, and censorship resistance.',
      color: 'text-red-600 dark:text-red-400'
    },
    {
      icon: Globe,
      title: 'Global Community',
      description: 'Connect with researchers worldwide in a truly decentralized academic network.',
      color: 'text-indigo-600 dark:text-indigo-400'
    }
  ];

  const stats = [
    { label: 'Research Papers', value: '10,000+' },
    { label: 'Active Researchers', value: '5,000+' },
    { label: 'Citations Generated', value: '50,000+' },
    { label: 'REZ Tokens Distributed', value: '1M+' }
  ];

  const testimonials = [
    {
      name: 'Dr. Sarah Chen',
      role: 'Quantum Computing Researcher, MIT',
      content: 'DeResNet has revolutionized how I share and discover research. The AI assistant helps me stay current with the latest developments.',
      rating: 5
    },
    {
      name: 'Prof. Michael Rodriguez',
      role: 'Climate Science, Stanford',
      content: 'The DAO governance model ensures fair funding allocation. Finally, researchers have a voice in how research is funded.',
      rating: 5
    },
    {
      name: 'Dr. Aisha Patel',
      role: 'Blockchain Research, Oxford',
      content: 'Publishing on ICP gives me confidence that my work will remain accessible and tamper-proof forever.',
      rating: 5
    }
  ];

  return (
    <div className="min-h-screen bg-white dark:bg-gray-900">
      {/* Hero Section */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-white to-purple-50 dark:from-gray-900 dark:via-gray-900 dark:to-blue-900/20"></div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-24">
          <div className="text-center">
            {/* Logo */}
            <div className="flex justify-center mb-8">
              <div className="flex items-center space-x-3">
                <div className="w-16 h-16 bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl flex items-center justify-center">
                  <span className="text-white font-bold text-2xl">DR</span>
                </div>
                <div>
                  <h1 className="text-4xl font-bold text-gray-900 dark:text-white">DeResNet</h1>
                  <p className="text-sm text-blue-600 dark:text-blue-400 font-medium">Powered by Internet Computer</p>
                </div>
              </div>
            </div>

            {/* Main Headline */}
            <h2 className="text-5xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6 leading-tight">
              The Future of
              <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent"> Academic Research</span>
            </h2>
            
            <p className="text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed">
              A decentralized research platform built on Internet Computer Protocol (ICP) that empowers researchers 
              with transparent publishing, democratic governance, and AI-powered insights.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
              <button
                onClick={handleGetStarted}
                className="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition-all duration-200 flex items-center justify-center space-x-2 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                <span>Get Started</span>
                <ArrowRight className="w-5 h-5" />
              </button>
              <button className="px-8 py-4 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-blue-600 dark:hover:border-blue-400 font-semibold rounded-xl transition-all duration-200">
                Learn More
              </button>
            </div>

            {/* ICP Badge */}
            <div className="inline-flex items-center space-x-2 bg-blue-50 dark:bg-blue-900/20 px-4 py-2 rounded-full">
              <Zap className="w-4 h-4 text-blue-600 dark:text-blue-400" />
              <span className="text-sm font-medium text-blue-700 dark:text-blue-300">
                Built on Internet Computer Protocol for maximum decentralization
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-gray-50 dark:bg-gray-800/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-2">
                  {stat.value}
                </div>
                <div className="text-gray-600 dark:text-gray-400 font-medium">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h3 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
              Revolutionizing Academic Research
            </h3>
            <p className="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
              DeResNet combines the power of blockchain technology with cutting-edge AI to create 
              the most advanced research platform ever built.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div key={index} className="bg-white dark:bg-gray-800 rounded-2xl p-8 border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-all duration-200 hover:-translate-y-1">
                  <div className={`w-12 h-12 rounded-xl bg-gray-100 dark:bg-gray-700 flex items-center justify-center mb-6`}>
                    <Icon className={`w-6 h-6 ${feature.color}`} />
                  </div>
                  <h4 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                    {feature.title}
                  </h4>
                  <p className="text-gray-600 dark:text-gray-300 leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ICP Integration Section */}
      <section className="py-24 bg-gradient-to-r from-blue-600 to-purple-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center text-white">
            <h3 className="text-3xl md:text-4xl font-bold mb-6">
              Powered by Internet Computer Protocol
            </h3>
            <p className="text-xl text-blue-100 mb-12 max-w-3xl mx-auto">
              DeResNet leverages ICP's revolutionary blockchain technology to provide 
              true decentralization, infinite scalability, and web-speed performance.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8">
                <Shield className="w-12 h-12 text-white mx-auto mb-4" />
                <h4 className="text-xl font-semibold mb-3">Tamper-Proof Storage</h4>
                <p className="text-blue-100">
                  Research papers and data stored immutably on-chain with cryptographic security.
                </p>
              </div>
              
              <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8">
                <TrendingUp className="w-12 h-12 text-white mx-auto mb-4" />
                <h4 className="text-xl font-semibold mb-3">Infinite Scalability</h4>
                <p className="text-blue-100">
                  ICP's unique architecture allows unlimited growth without compromising performance.
                </p>
              </div>
              
              <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8">
                <Zap className="w-12 h-12 text-white mx-auto mb-4" />
                <h4 className="text-xl font-semibold mb-3">Web-Speed Performance</h4>
                <p className="text-blue-100">
                  Experience traditional web performance with full blockchain benefits.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-24 bg-gray-50 dark:bg-gray-800/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h3 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
              Trusted by Leading Researchers
            </h3>
            <p className="text-xl text-gray-600 dark:text-gray-300">
              See what researchers around the world are saying about DeResNet
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="bg-white dark:bg-gray-800 rounded-2xl p-8 border border-gray-200 dark:border-gray-700">
                <div className="flex items-center mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 text-yellow-400 fill-current" />
                  ))}
                </div>
                <p className="text-gray-600 dark:text-gray-300 mb-6 italic">
                  "{testimonial.content}"
                </p>
                <div>
                  <div className="font-semibold text-gray-900 dark:text-white">
                    {testimonial.name}
                  </div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    {testimonial.role}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-24">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h3 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
            Ready to Transform Your Research?
          </h3>
          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8">
            Join thousands of researchers who are already using DeResNet to publish, 
            collaborate, and advance human knowledge.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button
              onClick={handleGetStarted}
              className="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition-all duration-200 flex items-center justify-center space-x-2 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
            >
              <span>Start Publishing Today</span>
              <ArrowRight className="w-5 h-5" />
            </button>
            <button className="px-8 py-4 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-blue-600 dark:hover:border-blue-400 font-semibold rounded-xl transition-all duration-200">
              View Documentation
            </button>
          </div>

          <div className="mt-8 flex items-center justify-center space-x-6 text-sm text-gray-500 dark:text-gray-400">
            <div className="flex items-center space-x-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              <span>Free to start</span>
            </div>
            <div className="flex items-center space-x-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              <span>No setup required</span>
            </div>
            <div className="flex items-center space-x-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              <span>Instant access</span>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 dark:bg-black text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold">DR</span>
                </div>
                <div>
                  <h4 className="text-xl font-bold">DeResNet</h4>
                  <p className="text-sm text-gray-400">Powered by Internet Computer</p>
                </div>
              </div>
              <p className="text-gray-400 mb-4 max-w-md">
                The world's first truly decentralized academic research platform, 
                built on Internet Computer Protocol for maximum security and scalability.
              </p>
              <div className="text-sm text-gray-500">
                © 2024 DeResNet. Built on ICP.
              </div>
            </div>
            
            <div>
              <h5 className="font-semibold mb-4">Platform</h5>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Research Papers</a></li>
                <li><a href="#" className="hover:text-white transition-colors">DAO Governance</a></li>
                <li><a href="#" className="hover:text-white transition-colors">AI Assistant</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Token Bridge</a></li>
              </ul>
            </div>
            
            <div>
              <h5 className="font-semibold mb-4">Resources</h5>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Documentation</a></li>
                <li><a href="#" className="hover:text-white transition-colors">API Reference</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Community</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Support</a></li>
              </ul>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;