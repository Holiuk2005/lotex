import React, { useState } from 'react';
import { Search, MoreVertical, Phone, Video } from 'lucide-react';
import { motion } from 'framer-motion';
export function ChatView() {
  const [activeTab, setActiveTab] = useState<'selling' | 'buying'>('selling');
  const chats = [{
    id: 1,
    name: 'Alex Chen',
    message: 'Is the neon artwork still available?',
    time: '2m ago',
    unread: 2,
    avatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&auto=format&fit=crop&q=60',
    role: 'selling'
  }, {
    id: 2,
    name: 'Sarah Miller',
    message: 'I just placed a bid!',
    time: '1h ago',
    unread: 0,
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=60',
    role: 'selling'
  }, {
    id: 3,
    name: 'Crypto King',
    message: 'Thanks for the quick transfer.',
    time: '3h ago',
    unread: 0,
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=60',
    role: 'buying'
  }, {
    id: 4,
    name: 'NFT Collector',
    message: 'Would you accept 4.5 ETH?',
    time: '1d ago',
    unread: 0,
    avatar: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&auto=format&fit=crop&q=60',
    role: 'buying'
  }];
  const filteredChats = chats.filter(chat => chat.role === activeTab);
  return <div className="flex h-full bg-slate-950">
      {/* Chat List */}
      <div className="w-full md:w-80 lg:w-96 border-r border-white/10 flex flex-col h-full">
        <div className="p-4 border-b border-white/10">
          <h1 className="text-xl font-bold text-white mb-4">Messages</h1>

          {/* Tabs */}
          <div className="flex p-1 bg-white/5 rounded-xl mb-4">
            <button onClick={() => setActiveTab('selling')} className={`flex-1 py-2 text-sm font-medium rounded-lg transition-all relative ${activeTab === 'selling' ? 'text-white' : 'text-slate-400 hover:text-slate-200'}`}>
              {activeTab === 'selling' && <motion.div layoutId="chatTab" className="absolute inset-0 bg-white/10 rounded-lg shadow-sm" transition={{
              type: 'spring',
              bounce: 0.2,
              duration: 0.6
            }} />}
              <span className="relative z-10">Продавець</span>
            </button>
            <button onClick={() => setActiveTab('buying')} className={`flex-1 py-2 text-sm font-medium rounded-lg transition-all relative ${activeTab === 'buying' ? 'text-white' : 'text-slate-400 hover:text-slate-200'}`}>
              {activeTab === 'buying' && <motion.div layoutId="chatTab" className="absolute inset-0 bg-white/10 rounded-lg shadow-sm" transition={{
              type: 'spring',
              bounce: 0.2,
              duration: 0.6
            }} />}
              <span className="relative z-10">Покупець</span>
            </button>
          </div>

          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input type="text" placeholder="Search messages..." className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-sm text-white placeholder:text-slate-500 focus:outline-none focus:border-violet-500 transition-colors" />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {filteredChats.length === 0 ? <div className="flex flex-col items-center justify-center h-40 text-slate-500">
              <p>No messages yet</p>
            </div> : filteredChats.map(chat => <div key={chat.id} className="p-4 hover:bg-white/5 cursor-pointer transition-colors border-b border-white/5">
                <div className="flex gap-3">
                  <div className="relative">
                    <img src={chat.avatar} alt={chat.name} className="w-12 h-12 rounded-full object-cover" />
                    {chat.unread > 0 && <div className="absolute -top-1 -right-1 w-5 h-5 bg-neon-orange rounded-full flex items-center justify-center text-[10px] font-bold text-white border-2 border-slate-950">
                        {chat.unread}
                      </div>}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start mb-1">
                      <h3 className="font-semibold text-white truncate">
                        {chat.name}
                      </h3>
                      <span className="text-xs text-slate-500 whitespace-nowrap">
                        {chat.time}
                      </span>
                    </div>
                    <p className={`text-sm truncate ${chat.unread > 0 ? 'text-white font-medium' : 'text-slate-400'}`}>
                      {chat.message}
                    </p>
                  </div>
                </div>
              </div>)}
        </div>
      </div>

      {/* Chat Window (Hidden on mobile if list is shown - simplified for this demo) */}
      <div className="hidden md:flex flex-1 flex-col bg-slate-900/50">
        <div className="p-4 border-b border-white/10 flex justify-between items-center bg-slate-950/50 backdrop-blur-md">
          <div className="flex items-center gap-3">
            <img src={chats[0].avatar} alt="" className="w-10 h-10 rounded-full object-cover" />
            <div>
              <h3 className="font-semibold text-white">{chats[0].name}</h3>
              <p className="text-xs text-green-400 flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
                Online
              </p>
            </div>
          </div>
          <div className="flex gap-2">
            <button className="p-2 hover:bg-white/10 rounded-full transition-colors text-slate-400 hover:text-white">
              <Phone className="w-5 h-5" />
            </button>
            <button className="p-2 hover:bg-white/10 rounded-full transition-colors text-slate-400 hover:text-white">
              <Video className="w-5 h-5" />
            </button>
            <button className="p-2 hover:bg-white/10 rounded-full transition-colors text-slate-400 hover:text-white">
              <MoreVertical className="w-5 h-5" />
            </button>
          </div>
        </div>

        <div className="flex-1 p-4 overflow-y-auto space-y-4">
          <div className="flex justify-center">
            <span className="text-xs text-slate-500 bg-white/5 px-3 py-1 rounded-full">
              Today
            </span>
          </div>
          <div className="flex justify-end">
            <div className="bg-violet-600 text-white px-4 py-2 rounded-2xl rounded-tr-sm max-w-[70%]">
              <p>Hi! Is this piece still available?</p>
              <span className="text-[10px] text-white/60 block text-right mt-1">
                10:42 AM
              </span>
            </div>
          </div>
          <div className="flex justify-start">
            <div className="bg-white/10 text-slate-200 px-4 py-2 rounded-2xl rounded-tl-sm max-w-[70%]">
              <p>Yes, the auction is live for another 2 hours!</p>
              <span className="text-[10px] text-slate-500 block mt-1">
                10:44 AM
              </span>
            </div>
          </div>
        </div>

        <div className="p-4 border-t border-white/10 bg-slate-950/50">
          <div className="flex gap-2">
            <input type="text" placeholder="Type a message..." className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white placeholder:text-slate-500 focus:outline-none focus:border-violet-500 transition-colors" />
            <button className="bg-violet-600 hover:bg-violet-500 text-white px-6 py-2 rounded-xl font-medium transition-colors">
              Send
            </button>
          </div>
        </div>
      </div>
    </div>;
}