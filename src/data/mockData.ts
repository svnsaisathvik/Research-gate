export interface Paper {
  id: string;
  title: string;
  abstract: string;
  authors: string[];
  institution: string;
  publishedDate: string;
  tags: string[];
  citations: number;
  downloads: number;
  doi?: string;
  status: 'published' | 'under-review' | 'draft';
  fileUrl?: string;
}

export interface DAOProposal {
  id: string;
  title: string;
  description: string;
  type: 'grant' | 'review' | 'governance';
  proposer: string;
  votesFor: number;
  votesAgainst: number;
  totalVotes: number;
  endDate: string;
  status: 'active' | 'passed' | 'rejected';
  requiredTokens: number;
}

export const mockPapers: Paper[] = [
  {
    id: '1',
    title: 'Quantum Computing Applications in Cryptography: A Comprehensive Review',
    abstract: 'This paper explores the intersection of quantum computing and cryptographic systems, analyzing both opportunities and threats posed by quantum algorithms to current security infrastructure.',
    authors: ['Dr. Alice Johnson', 'Prof. Bob Smith'],
    institution: 'MIT',
    publishedDate: '2024-01-15',
    tags: ['quantum computing', 'cryptography', 'security', 'algorithms'],
    citations: 42,
    downloads: 1250,
    doi: '10.1000/182',
    status: 'published'
  },
  {
    id: '2',
    title: 'Machine Learning Approaches to Climate Change Prediction',
    abstract: 'We present novel machine learning models for improved climate prediction accuracy, incorporating satellite data and advanced neural network architectures.',
    authors: ['Dr. Carol Williams', 'Dr. David Brown', 'Prof. Eve Davis'],
    institution: 'Stanford University',
    publishedDate: '2024-01-10',
    tags: ['machine learning', 'climate change', 'prediction', 'neural networks'],
    citations: 28,
    downloads: 892,
    doi: '10.1000/183',
    status: 'published'
  },
  {
    id: '3',
    title: 'Blockchain Technology in Supply Chain Management: Challenges and Solutions',
    abstract: 'An analysis of blockchain implementation in supply chain systems, focusing on transparency, traceability, and efficiency improvements.',
    authors: ['Prof. Frank Miller', 'Dr. Grace Wilson'],
    institution: 'Harvard University',
    publishedDate: '2024-01-05',
    tags: ['blockchain', 'supply chain', 'transparency', 'efficiency'],
    citations: 35,
    downloads: 673,
    status: 'under-review'
  }
];

export const mockProposals: DAOProposal[] = [
  {
    id: '1',
    title: 'Research Grant for Quantum AI Development',
    description: 'Proposal to allocate 10,000 REZ tokens for research into quantum artificial intelligence applications in drug discovery.',
    type: 'grant',
    proposer: 'Dr. Alice Johnson',
    votesFor: 1250,
    votesAgainst: 340,
    totalVotes: 1590,
    endDate: '2024-02-15',
    status: 'active',
    requiredTokens: 100
  },
  {
    id: '2',
    title: 'New Peer Review Standards Implementation',
    description: 'Implement enhanced peer review standards with mandatory conflict of interest declarations and double-blind review process.',
    type: 'governance',
    proposer: 'Prof. Bob Smith',
    votesFor: 2100,
    votesAgainst: 450,
    totalVotes: 2550,
    endDate: '2024-02-10',
    status: 'passed',
    requiredTokens: 50
  },
  {
    id: '3',
    title: 'Climate Research Emergency Fund',
    description: 'Establish emergency funding pool of 25,000 REZ tokens for urgent climate research initiatives.',
    type: 'grant',
    proposer: 'Dr. Carol Williams',
    votesFor: 890,
    votesAgainst: 1200,
    totalVotes: 2090,
    endDate: '2024-01-30',
    status: 'rejected',
    requiredTokens: 75
  }
];

export const mockUser = {
  id: '1',
  name: 'Dr. Sarah Chen',
  email: 'sarah.chen@university.edu',
  institution: 'MIT',
  reputation: 4.8,
  rezTokens: 2500
};