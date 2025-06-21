import React from 'react';
import { FileText, Users, TrendingUp, Award, Clock, Download } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { mockPapers, mockProposals } from '../../data/mockData';

const Dashboard: React.FC = () => {
  const { user } = useAuth();

  const stats = [
    {
      label: 'Published Papers',
      value: '12',
      change: '+2 this month',
      icon: FileText,
      color: 'text-blue-600 dark:text-blue-400'
    },
    {
      label: 'Citations',
      value: '1,247',
      change: '+89 this month',
      icon: Award,
      color: 'text-green-600 dark:text-green-400'
    },
    {
      label: 'Collaborators',
      value: '34',
      change: '+5 this month',
      icon: Users,
      color: 'text-purple-600 dark:text-purple-400'
    },
    {
      label: 'REZ Tokens',
      value: user?.rezTokens?.toLocaleString() || '0',
      change: '+150 this week',
      icon: TrendingUp,
      color: 'text-orange-600 dark:text-orange-400'
    }
  ];

  const recentPapers = mockPapers.slice(0, 3);
  const activeProposals = mockProposals.filter(p => p.status === 'active');

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl p-8 text-white">
        <h1 className="text-3xl font-bold mb-2">
          Welcome back, {user?.name || 'Researcher'}!
        </h1>
        <p className="text-blue-100 text-lg">
          Continue your journey in decentralized research collaboration
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white dark:bg-gray-800 rounded-xl p-6 border border-gray-200 dark:border-gray-700">
              <div className="flex items-center justify-between mb-4">
                <Icon className={`w-8 h-8 ${stat.color}`} />
                <span className="text-sm text-green-600 dark:text-green-400">{stat.change}</span>
              </div>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-1">
                {stat.value}
              </h3>
              <p className="text-gray-500 dark:text-gray-400 text-sm">{stat.label}</p>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Recent Papers */}
        <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700">
          <div className="p-6 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
              Recent Papers
            </h2>
          </div>
          <div className="p-6 space-y-4">
            {recentPapers.map((paper) => (
              <div key={paper.id} className="flex items-start space-x-4 p-4 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg transition-colors">
                <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center flex-shrink-0">
                  <FileText className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-sm font-medium text-gray-900 dark:text-white line-clamp-2">
                    {paper.title}
                  </h3>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    {paper.authors.join(', ')} • {paper.publishedDate}
                  </p>
                  <div className="flex items-center space-x-4 mt-2 text-xs text-gray-500 dark:text-gray-400">
                    <span className="flex items-center">
                      <Award className="w-3 h-3 mr-1" />
                      {paper.citations} citations
                    </span>
                    <span className="flex items-center">
                      <Download className="w-3 h-3 mr-1" />
                      {paper.downloads} downloads
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Active DAO Proposals */}
        <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700">
          <div className="p-6 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
              Active Proposals
            </h2>
          </div>
          <div className="p-6 space-y-4">
            {activeProposals.map((proposal) => (
              <div key={proposal.id} className="p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
                <div className="flex items-start justify-between mb-3">
                  <h3 className="text-sm font-medium text-gray-900 dark:text-white line-clamp-2">
                    {proposal.title}
                  </h3>
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    proposal.type === 'grant' 
                      ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
                      : 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300'
                  }`}>
                    {proposal.type}
                  </span>
                </div>
                <p className="text-xs text-gray-500 dark:text-gray-400 mb-3 line-clamp-2">
                  {proposal.description}
                </p>
                <div className="flex items-center justify-between text-xs">
                  <div className="flex items-center text-gray-500 dark:text-gray-400">
                    <Clock className="w-3 h-3 mr-1" />
                    Ends {proposal.endDate}
                  </div>
                  <div className="text-gray-900 dark:text-white font-medium">
                    {Math.round((proposal.votesFor / proposal.totalVotes) * 100)}% support
                  </div>
                </div>
              </div>
            ))}
            {activeProposals.length === 0 && (
              <p className="text-center text-gray-500 dark:text-gray-400 py-8">
                No active proposals at the moment
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;