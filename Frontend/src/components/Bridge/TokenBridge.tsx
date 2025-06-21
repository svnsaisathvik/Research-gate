import React, { useState } from 'react';
import { ArrowRight, Coins, RefreshCw, ExternalLink, AlertCircle } from 'lucide-react';

const TokenBridge: React.FC = () => {
  const [fromChain, setFromChain] = useState('ethereum');
  const [toChain, setToChain] = useState('icp');
  const [fromToken, setFromToken] = useState('ETH');
  const [toToken, setToToken] = useState('REZ');
  const [amount, setAmount] = useState('');
  const [isSwapping, setIsSwapping] = useState(false);

  const chains = [
    { id: 'ethereum', name: 'Ethereum', symbol: 'ETH' },
    { id: 'icp', name: 'Internet Computer', symbol: 'ICP' },
    { id: 'bitcoin', name: 'Bitcoin', symbol: 'BTC' }
  ];

  const tokens = {
    ethereum: ['ETH', 'USDT', 'USDC', 'DAI'],
    icp: ['ICP', 'REZ', 'ckBTC', 'ckETH'],
    bitcoin: ['BTC']
  };

  const exchangeRates = {
    'ETH/REZ': 1250,
    'USDT/REZ': 0.5,
    'ICP/REZ': 12.5,
    'BTC/REZ': 25000
  };

  const handleSwap = async () => {
    if (!amount || parseFloat(amount) <= 0) return;
    
    setIsSwapping(true);
    
    // Simulate bridge transaction
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    alert(`Successfully bridged ${amount} ${fromToken} to ${calculateOutput()} ${toToken}!`);
    setIsSwapping(false);
    setAmount('');
  };

  const calculateOutput = () => {
    if (!amount) return '0';
    
    const inputAmount = parseFloat(amount);
    const rateKey = `${fromToken}/${toToken}` as keyof typeof exchangeRates;
    const rate = exchangeRates[rateKey] || 1;
    
    return (inputAmount * rate).toFixed(2);
  };

  const swapChains = () => {
    const tempChain = fromChain;
    const tempToken = fromToken;
    
    setFromChain(toChain);
    setToChain(tempChain);
    
    // Update tokens based on new chains
    const newFromTokens = tokens[toChain as keyof typeof tokens];
    const newToTokens = tokens[tempChain as keyof typeof tokens];
    
    setFromToken(newFromTokens[0]);
    setToToken(newToTokens.includes('REZ') ? 'REZ' : newToTokens[0]);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Multi-Chain Token Bridge
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Bridge tokens between different blockchains to participate in DeResNet
        </p>
      </div>

      {/* Bridge Interface */}
      <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-8">
        {/* From Section */}
        <div className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
              From
            </label>
            <div className="border border-gray-300 dark:border-gray-600 rounded-lg p-4">
              <div className="flex items-center justify-between mb-4">
                <select
                  value={fromChain}
                  onChange={(e) => {
                    setFromChain(e.target.value);
                    const newTokens = tokens[e.target.value as keyof typeof tokens];
                    setFromToken(newTokens[0]);
                  }}
                  className="bg-transparent text-gray-900 dark:text-white font-medium focus:outline-none"
                >
                  {chains.map(chain => (
                    <option key={chain.id} value={chain.id}>
                      {chain.name}
                    </option>
                  ))}
                </select>
                <select
                  value={fromToken}
                  onChange={(e) => setFromToken(e.target.value)}
                  className="bg-transparent text-gray-900 dark:text-white font-medium focus:outline-none"
                >
                  {tokens[fromChain as keyof typeof tokens].map(token => (
                    <option key={token} value={token}>
                      {token}
                    </option>
                  ))}
                </select>
              </div>
              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="0.00"
                className="w-full text-2xl font-bold bg-transparent text-gray-900 dark:text-white placeholder-gray-400 focus:outline-none"
              />
              <div className="flex items-center justify-between mt-2 text-sm text-gray-500 dark:text-gray-400">
                <span>Balance: 12.34 {fromToken}</span>
                <button className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300">
                  Max
                </button>
              </div>
            </div>
          </div>

          {/* Swap Button */}
          <div className="flex justify-center">
            <button
              onClick={swapChains}
              className="p-2 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-full transition-colors"
            >
              <RefreshCw className="w-5 h-5 text-gray-600 dark:text-gray-400" />
            </button>
          </div>

          {/* To Section */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
              To
            </label>
            <div className="border border-gray-300 dark:border-gray-600 rounded-lg p-4 bg-gray-50 dark:bg-gray-700">
              <div className="flex items-center justify-between mb-4">
                <select
                  value={toChain}
                  onChange={(e) => {
                    setToChain(e.target.value);
                    const newTokens = tokens[e.target.value as keyof typeof tokens];
                    setToToken(newTokens.includes('REZ') ? 'REZ' : newTokens[0]);
                  }}
                  className="bg-transparent text-gray-900 dark:text-white font-medium focus:outline-none"
                >
                  {chains.map(chain => (
                    <option key={chain.id} value={chain.id}>
                      {chain.name}
                    </option>
                  ))}
                </select>
                <select
                  value={toToken}
                  onChange={(e) => setToToken(e.target.value)}
                  className="bg-transparent text-gray-900 dark:text-white font-medium focus:outline-none"
                >
                  {tokens[toChain as keyof typeof tokens].map(token => (
                    <option key={token} value={token}>
                      {token}
                    </option>
                  ))}
                </select>
              </div>
              <div className="text-2xl font-bold text-gray-900 dark:text-white">
                {calculateOutput()}
              </div>
              <div className="text-sm text-gray-500 dark:text-gray-400 mt-2">
                Balance: 2,500 {toToken}
              </div>
            </div>
          </div>
        </div>

        {/* Bridge Details */}
        <div className="mt-8 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <div className="flex items-start space-x-3">
            <AlertCircle className="w-5 h-5 text-blue-600 dark:text-blue-400 mt-0.5 flex-shrink-0" />
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-600 dark:text-gray-400">Exchange Rate:</span>
                <span className="text-gray-900 dark:text-white font-medium">
                  1 {fromToken} = {exchangeRates[`${fromToken}/${toToken}` as keyof typeof exchangeRates] || '1'} {toToken}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600 dark:text-gray-400">Bridge Fee:</span>
                <span className="text-gray-900 dark:text-white font-medium">0.1%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600 dark:text-gray-400">Estimated Time:</span>
                <span className="text-gray-900 dark:text-white font-medium">5-10 minutes</span>
              </div>
            </div>
          </div>
        </div>

        {/* Bridge Button */}
        <button
          onClick={handleSwap}
          disabled={!amount || parseFloat(amount) <= 0 || isSwapping}
          className="w-full mt-8 py-4 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold rounded-lg transition-colors flex items-center justify-center space-x-2"
        >
          {isSwapping ? (
            <>
              <RefreshCw className="w-5 h-5 animate-spin" />
              <span>Bridging...</span>
            </>
          ) : (
            <>
              <span>Bridge Tokens</span>
              <ArrowRight className="w-5 h-5" />
            </>
          )}
        </button>
      </div>

      {/* Recent Transactions */}
      <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700">
        <div className="p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
            Recent Transactions
          </h2>
        </div>
        <div className="p-6">
          <div className="space-y-4">
            {[
              { from: 'ETH', to: 'REZ', amount: '1.5', status: 'completed', time: '2 hours ago', hash: '0x1234...5678' },
              { from: 'USDT', to: 'REZ', amount: '100', status: 'pending', time: '5 minutes ago', hash: '0x8765...4321' },
              { from: 'ICP', to: 'REZ', amount: '50', status: 'completed', time: '1 day ago', hash: '0x9876...1234' }
            ].map((tx, index) => (
              <div key={index} className="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
                <div className="flex items-center space-x-4">
                  <div className="flex items-center space-x-2">
                    <Coins className="w-5 h-5 text-gray-400" />
                    <span className="font-medium text-gray-900 dark:text-white">
                      {tx.amount} {tx.from} → {tx.to}
                    </span>
                  </div>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    tx.status === 'completed' 
                      ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
                      : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
                  }`}>
                    {tx.status}
                  </span>
                </div>
                <div className="flex items-center space-x-4 text-sm text-gray-500 dark:text-gray-400">
                  <span>{tx.time}</span>
                  <button className="flex items-center space-x-1 text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300">
                    <span>{tx.hash}</span>
                    <ExternalLink className="w-3 h-3" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TokenBridge;