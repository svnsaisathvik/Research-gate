import React from 'react';
import { 
  Home, 
  FileText, 
  Upload, 
  Vote, 
  MessageSquare, 
  Coins, 
  TrendingUp,
  Settings,
  Users
} from 'lucide-react';

interface SidebarProps {
  currentPage: string;
  onPageChange: (page: string) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ currentPage, onPageChange }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: Home },
    { id: 'papers', label: 'Papers', icon: FileText },
    { id: 'submit', label: 'Submit Paper', icon: Upload },
    { id: 'dao', label: 'DAO Voting', icon: Vote },
    { id: 'ai-chat', label: 'AI Assistant', icon: MessageSquare },
    { id: 'bridge', label: 'Token Bridge', icon: Coins },
    { id: 'analytics', label: 'Analytics', icon: TrendingUp },
    { id: 'community', label: 'Community', icon: Users },
    { id: 'settings', label: 'Settings', icon: Settings },
  ];

  return (
    <div className="w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-700 h-full">
      <nav className="mt-8">
        <div className="px-4">
          <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-4">
            Research Platform
          </p>
        </div>
        <div className="space-y-1 px-2">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentPage === item.id;
            
            return (
              <button
                key={item.id}
                onClick={() => onPageChange(item.id)}
                className={`w-full flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors ${
                  isActive
                    ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 border-r-2 border-blue-600'
                    : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800'
                }`}
              >
                <Icon className="w-5 h-5 mr-3" />
                {item.label}
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
};

export default Sidebar;