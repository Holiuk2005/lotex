import React, { useState } from 'react';
import { AnimatedBackground } from './components/AnimatedBackground';
import { AuctionGrid } from './components/AuctionGrid';
import { AppLayout } from './components/AppLayout';
import { AuctionDetail } from './components/AuctionDetail';
import { ProfileView } from './components/ProfileView';
import { ChatView } from './components/ChatView';
import { FavoritesView } from './components/FavoritesView';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, Bell, Filter } from 'lucide-react';
// Mock Data
const ALL_ITEMS = [{
  id: '1',
  title: 'Cosmic Perspective #42',
  artist: 'Elena Void',
  currentBid: 4.2,
  image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 2,
    minutes: 14,
    seconds: 0
  },
  progress: 85,
  category: 'live'
}, {
  id: '2',
  title: 'Neon Genesis',
  artist: 'Cyber Punk',
  currentBid: 1.8,
  image: 'https://images.unsplash.com/photo-1563089145-599997674d42?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 5,
    minutes: 30,
    seconds: 0
  },
  progress: 60,
  category: 'live'
}, {
  id: '3',
  title: 'Abstract Thoughts',
  artist: 'Mind Walker',
  currentBid: 0.5,
  image: 'https://images.unsplash.com/photo-1541963463532-d68292c34b19?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 12,
    minutes: 0,
    seconds: 0
  },
  progress: 40,
  category: 'upcoming'
}, {
  id: '4',
  title: 'Digital Dreams',
  artist: 'Pixel Master',
  currentBid: 8.5,
  image: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 1,
    minutes: 5,
    seconds: 0
  },
  progress: 92,
  category: 'live'
}, {
  id: '5',
  title: 'Future City',
  artist: 'Arch Tech',
  currentBid: 2.1,
  image: 'https://images.unsplash.com/photo-1573455494060-c5595004fb6c?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 24,
    minutes: 0,
    seconds: 0
  },
  progress: 10,
  category: 'upcoming'
}, {
  id: '6',
  title: 'Ethereal Flow',
  artist: 'Aura',
  currentBid: 3.3,
  image: 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?q=80&w=1000&auto=format&fit=crop',
  timeLeft: {
    hours: 0,
    minutes: 45,
    seconds: 0
  },
  progress: 95,
  category: 'live'
}];
const TABS = [{
  id: 'live',
  label: 'Live Auctions'
}, {
  id: 'upcoming',
  label: 'Upcoming'
}, {
  id: 'ended',
  label: 'Ended'
}];
export function App() {
  const [activeTab, setActiveTab] = useState('home');
  const [auctionFilter, setAuctionFilter] = useState('live');
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const filteredItems = auctionFilter === 'live' ? ALL_ITEMS.filter(item => item.category === 'live') : auctionFilter === 'upcoming' ? ALL_ITEMS.filter(item => item.category === 'upcoming') : [];
  const renderContent = () => {
    if (selectedItem) {
      return <AuctionDetail item={selectedItem} onBack={() => setSelectedItem(null)} />;
    }
    switch (activeTab) {
      case 'profile':
        return <ProfileView />;
      case 'chat':
        return <ChatView />;
      case 'favorites':
        return <FavoritesView />;
      case 'sell':
        return <div className="flex flex-col items-center justify-center h-full text-center p-8">
            <div className="w-20 h-20 rounded-full bg-gradient-to-r from-violet-600 to-blue-600 flex items-center justify-center mb-6 shadow-glow">
              <span className="text-4xl">✨</span>
            </div>
            <h2 className="text-2xl font-bold text-white mb-2">
              Create New Listing
            </h2>
            <p className="text-slate-400 max-w-sm">
              Upload your digital artwork or collectible to start an auction.
            </p>
          </div>;
      case 'home':
      default:
        return <div className="flex flex-col h-full">
            {/* Header */}
            <header className="px-4 md:px-8 py-5 flex items-center justify-between backdrop-blur-sm border-b border-white/5 sticky top-0 z-20 bg-slate-950/80">
              <div className="md:hidden flex items-center gap-2">
                <span className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-slate-400">
                  Lotex
                </span>
              </div>

              <div className="hidden md:flex flex-1 max-w-md relative mx-4">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                <input type="text" placeholder="Search auctions, artists, or collections..." className="w-full bg-white/5 border border-white/10 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder:text-slate-500 focus:outline-none focus:border-violet-500 transition-colors" />
              </div>

              <div className="flex items-center gap-3">
                <button className="p-2 text-slate-400 hover:text-white hover:bg-white/10 rounded-full transition-all relative">
                  <Bell className="w-5 h-5" />
                  <span className="absolute top-2 right-2 w-2 h-2 bg-neon-orange rounded-full border-2 border-slate-950"></span>
                </button>
                <div className="hidden md:block w-9 h-9 rounded-full bg-gradient-to-r from-pink-500 to-orange-400 p-[2px] cursor-pointer" onClick={() => setActiveTab('profile')}>
                  <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100&auto=format&fit=crop" alt="Profile" className="w-full h-full rounded-full object-cover border-2 border-slate-950" />
                </div>
              </div>
            </header>

            <div className="flex-1 overflow-y-auto">
              <div className="px-4 md:px-8 py-8">
                {/* Hero / Welcome */}
                <motion.div initial={{
                opacity: 0,
                y: 20
              }} animate={{
                opacity: 1,
                y: 0
              }} className="mb-10 max-w-4xl">
                  <h1 className="text-4xl md:text-5xl font-bold text-white mb-4 leading-tight">
                    Discover Rare <br />
                    <span className="text-transparent bg-clip-text bg-gradient-to-r from-violet-400 via-pink-400 to-blue-400">
                      Digital Artifacts
                    </span>
                  </h1>
                </motion.div>

                {/* Filters */}
                <div className="flex items-center gap-4 mb-8 overflow-x-auto pb-2 scrollbar-hide">
                  <button className="p-2 bg-white/5 border border-white/10 rounded-lg text-slate-400 hover:text-white transition-colors">
                    <Filter className="w-5 h-5" />
                  </button>
                  {TABS.map(tab => <button key={tab.id} onClick={() => setAuctionFilter(tab.id)} className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all ${auctionFilter === tab.id ? 'bg-white text-slate-950' : 'bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white'}`}>
                      {tab.label}
                    </button>)}
                </div>

                {/* Grid Content */}
                <AuctionGrid items={filteredItems} onSelect={setSelectedItem} />

                {filteredItems.length === 0 && <div className="flex flex-col items-center justify-center py-20 text-slate-500">
                    <p>No auctions found in this category.</p>
                  </div>}
              </div>
            </div>
          </div>;
    }
  };
  return <div className="min-h-screen bg-slate-950 text-slate-200 font-sans selection:bg-violet-500/30">
      <AnimatedBackground />
      <AppLayout activeTab={activeTab} onTabChange={tab => {
      setActiveTab(tab);
      setSelectedItem(null);
    }}>
        <AnimatePresence mode="wait">
          <motion.div key={activeTab + (selectedItem ? '-detail' : '')} initial={{
          opacity: 0,
          y: 10
        }} animate={{
          opacity: 1,
          y: 0
        }} exit={{
          opacity: 0,
          y: -10
        }} transition={{
          duration: 0.2
        }} className="h-full relative z-10">
            {renderContent()}
          </motion.div>
        </AnimatePresence>
      </AppLayout>
    </div>;
}