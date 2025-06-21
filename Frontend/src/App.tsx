import React, { useState } from 'react';
import { ThemeProvider } from './contexts/ThemeContext';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Header from './components/Layout/Header';
import Sidebar from './components/Layout/Sidebar';
import Dashboard from './components/Dashboard/Dashboard';
import PaperLibrary from './components/Papers/PaperLibrary';
import SubmitPaper from './components/Papers/SubmitPaper';
import DAOVoting from './components/DAO/DAOVoting';
import AIChat from './components/AI/AIChat';
import TokenBridge from './components/Bridge/TokenBridge';
import LandingPage from './components/Landing/LandingPage';

const AppContent: React.FC = () => {
  const { isAuthenticated } = useAuth();
  const [currentPage, setCurrentPage] = useState('dashboard');

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard />;
      case 'papers':
        return <PaperLibrary />;
      case 'submit':
        return <SubmitPaper />;
      case 'dao':
        return <DAOVoting />;
      case 'ai-chat':
        return <AIChat />;
      case 'bridge':
        return <TokenBridge />;
      case 'analytics':
        return (
          <div className="text-center py-12">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Analytics Dashboard
            </h2>
            <p className="text-gray-600 dark:text-gray-400">
              Coming soon - Advanced research analytics and insights
            </p>
          </div>
        );
      case 'community':
        return (
          <div className="text-center py-12">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Research Community
            </h2>
            <p className="text-gray-600 dark:text-gray-400">
              Coming soon - Connect with researchers worldwide
            </p>
          </div>
        );
      case 'settings':
        return (
          <div className="text-center py-12">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Settings
            </h2>
            <p className="text-gray-600 dark:text-gray-400">
              Coming soon - Customize your research experience
            </p>
          </div>
        );
      default:
        return <Dashboard />;
    }
  };

  if (!isAuthenticated) {
    return <LandingPage onGetStarted={() => setCurrentPage('dashboard')} />;
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors">
      <Header />
      <div className="flex">
        <Sidebar currentPage={currentPage} onPageChange={setCurrentPage} />
        <main className="flex-1 p-8">
          {renderPage()}
        </main>
      </div>
    </div>
  );
};

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;