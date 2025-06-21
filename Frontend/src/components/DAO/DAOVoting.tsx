import React, { useState } from 'react';
import { Vote, Clock, CheckCircle, XCircle, Users, Coins } from 'lucide-react';
import { mockProposals, DAOProposal } from '../../data/mockData';
import { useAuth } from '../../contexts/AuthContext';

const DAOVoting: React.FC = () => {
  const { user } = useAuth();
  const [selectedTab, setSelectedTab] = useState<'active' | 'passed' | 'rejected'>('active');
  const [votingStates, setVotingStates] = useState<{[key: string]: 'for' | 'against' | null}>({});

  const filterProposals = (status: DAOProposal['status']) => {
    return mockProposals.filter(proposal => proposal.status === status);
  };

  const handleVote = (proposalId: string, vote: 'for' | 'against') => {
    if (!user) return;
    
    setVotingStates(prev => ({ ...prev, [proposalId]: vote }));
    
    // Simulate voting transaction
    setTimeout(() => {
      alert(`Vote submitted successfully! Your ${vote} vote has been recorded.`);
    }, 1000);
  };

  const getStatusIcon = (status: DAOProposal['status']) => {
    switch (status) {
      case 'active':
        return <Clock className="w-5 h-5 text-blue-600" />;
      case 'passed':
        return <CheckCircle className="w-5 h-5 text-green-600" />;
      case 'rejected':
        return <XCircle className="w-5 h-5 text-red-600" />;
    }
  };

  const getStatusColor = (status: DAOProposal['status']) => {
    switch (status) {
      case 'active':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300';
      case 'passed':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
      case 'rejected':
        return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300';
    }
  };

  const getTypeColor = (type: DAOProposal['type']) => {
    switch (type) {
      case 'grant':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
      case 'review':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300';
      case 'governance':
        return 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const tabs = [
    { id: 'active' as const, label: 'Active Proposals', count: filterProposals('active').length },
    { id: 'passed' as const, label: 'Passed', count: filterProposals('passed').length },
    { id: 'rejected' as const, label: 'Rejected', count: filterProposals('rejected').length }
  ];

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          DAO Governance
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Participate in decentralized decision-making for the research community
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Your REZ Balance</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {user?.rezTokens?.toLocaleString() || '0'}
              </p>
            </div>
            <Coins className="w-8 h-8 text-orange-600" />
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Voting Power</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {Math.round((user?.rezTokens || 0) / 100)}
              </p>
            </div>
            <Vote className="w-8 h-8 text-blue-600" />
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Proposals Voted</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">12</p>
            </div>
            <Users className="w-8 h-8 text-green-600" />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700">
        <div className="border-b border-gray-200 dark:border-gray-700">
          <nav className="flex space-x-8 px-6" aria-label="Tabs">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setSelectedTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                  selectedTab === tab.id
                    ? 'border-blue-500 text-blue-600 dark:text-blue-400'
                    : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'
                }`}
              >
                {tab.label}
                <span className={`ml-2 py-0.5 px-2 rounded-full text-xs ${
                  selectedTab === tab.id
                    ? 'bg-blue-100 text-blue-600 dark:bg-blue-900 dark:text-blue-400'
                    : 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400'
                }`}>
                  {tab.count}
                </span>
              </button>
            ))}
          </nav>
        </div>

        {/* Proposals */}
        <div className="p-6">
          <div className="space-y-6">
            {filterProposals(selectedTab).map((proposal) => (
              <div key={proposal.id} className="border border-gray-200 dark:border-gray-600 rounded-lg p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-2">
                      {getStatusIcon(proposal.status)}
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                        {proposal.title}
                      </h3>
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(proposal.status)}`}>
                        {proposal.status}
                      </span>
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getTypeColor(proposal.type)}`}>
                        {proposal.type}
                      </span>
                    </div>
                    
                    <p className="text-gray-600 dark:text-gray-300 mb-4">
                      {proposal.description}
                    </p>

                    <div className="flex items-center space-x-6 text-sm text-gray-500 dark:text-gray-400 mb-4">
                      <span>Proposed by {proposal.proposer}</span>
                      <span>Ends {formatDate(proposal.endDate)}</span>
                      <span>Min. {proposal.requiredTokens} REZ to vote</span>
                    </div>

                    {/* Voting Stats */}
                    <div className="space-y-3">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-600 dark:text-gray-400">
                          {proposal.totalVotes.toLocaleString()} total votes
                        </span>
                        <span className="font-medium text-gray-900 dark:text-white">
                          {Math.round((proposal.votesFor / proposal.totalVotes) * 100)}% support
                        </span>
                      </div>
                      
                      {/* Progress Bar */}
                      <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                        <div 
                          className="bg-green-600 h-2 rounded-full transition-all duration-300"
                          style={{ width: `${(proposal.votesFor / proposal.totalVotes) * 100}%` }}
                        />
                      </div>
                      
                      <div className="flex justify-between text-sm text-gray-600 dark:text-gray-400">
                        <span className="flex items-center">
                          <CheckCircle className="w-4 h-4 mr-1 text-green-600" />
                          {proposal.votesFor.toLocaleString()} for
                        </span>
                        <span className="flex items-center">
                          <XCircle className="w-4 h-4 mr-1 text-red-600" />
                          {proposal.votesAgainst.toLocaleString()} against
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Voting Actions */}
                  {proposal.status === 'active' && user && user.rezTokens >= proposal.requiredTokens && (
                    <div className="ml-6 flex flex-col space-y-2">
                      <button
                        onClick={() => handleVote(proposal.id, 'for')}
                        disabled={votingStates[proposal.id] !== undefined}
                        className="px-4 py-2 bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium rounded-lg transition-colors"
                      >
                        {votingStates[proposal.id] === 'for' ? 'Voted For' : 'Vote For'}
                      </button>
                      <button
                        onClick={() => handleVote(proposal.id, 'against')}
                        disabled={votingStates[proposal.id] !== undefined}
                        className="px-4 py-2 bg-red-600 hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium rounded-lg transition-colors"
                      >
                        {votingStates[proposal.id] === 'against' ? 'Voted Against' : 'Vote Against'}
                      </button>
                    </div>
                  )}
                  
                  {proposal.status === 'active' && (!user || user.rezTokens < proposal.requiredTokens) && (
                    <div className="ml-6 text-center">
                      <p className="text-sm text-gray-500 dark:text-gray-400 mb-2">
                        {!user ? 'Login to vote' : `Need ${proposal.requiredTokens} REZ`}
                      </p>
                      <button
                        disabled
                        className="px-4 py-2 bg-gray-300 dark:bg-gray-600 text-gray-500 dark:text-gray-400 text-sm font-medium rounded-lg cursor-not-allowed"
                      >
                        Vote
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}

            {filterProposals(selectedTab).length === 0 && (
              <div className="text-center py-12">
                <Vote className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
                  No {selectedTab} proposals
                </h3>
                <p className="text-gray-500 dark:text-gray-400">
                  Check back later for new proposals to vote on
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DAOVoting;