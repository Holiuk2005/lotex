import React from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, Heart, Share2, Clock, TrendingUp, ShieldCheck, User } from 'lucide-react';
interface AuctionDetailProps {
  item: any;
  onBack: () => void;
}
export function AuctionDetail({
  item,
  onBack
}: AuctionDetailProps) {
  return <motion.div initial={{
    opacity: 0,
    x: 20
  }} animate={{
    opacity: 1,
    x: 0
  }} exit={{
    opacity: 0,
    x: -20
  }} className="flex flex-col h-full bg-slate-950">
      {/* Header */}
      <header className="sticky top-0 z-20 flex items-center justify-between p-4 bg-slate-950/80 backdrop-blur-xl border-b border-white/10">
        <button onClick={onBack} className="p-2 hover:bg-white/10 rounded-full transition-colors">
          <ArrowLeft className="w-6 h-6 text-white" />
        </button>
        <h1 className="text-lg font-bold text-white truncate max-w-[200px]">
          {item.title}
        </h1>
        <div className="flex gap-2">
          <button className="p-2 hover:bg-white/10 rounded-full transition-colors">
            <Share2 className="w-5 h-5 text-slate-400" />
          </button>
          <button className="p-2 hover:bg-white/10 rounded-full transition-colors">
            <Heart className="w-5 h-5 text-slate-400" />
          </button>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto">
        <div className="max-w-6xl mx-auto w-full">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 p-4 lg:p-8">
            {/* Image Gallery */}
            <div className="space-y-4">
              <div className="aspect-square rounded-2xl overflow-hidden border border-white/10 relative group">
                <img src={item.image} alt={item.title} className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
                <div className="absolute top-4 left-4 bg-black/60 backdrop-blur-md px-3 py-1 rounded-full border border-white/10 flex items-center gap-2">
                  <span className="relative flex h-2 w-2">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                  </span>
                  <span className="text-xs font-medium text-white">
                    Live Auction
                  </span>
                </div>
              </div>
              <div className="grid grid-cols-4 gap-4">
                {[1, 2, 3, 4].map(i => <div key={i} className="aspect-square rounded-xl overflow-hidden border border-white/10 cursor-pointer hover:border-violet-500 transition-colors">
                    <img src={item.image} alt="" className="w-full h-full object-cover opacity-60 hover:opacity-100 transition-opacity" />
                  </div>)}
              </div>
            </div>

            {/* Details */}
            <div className="space-y-8">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="px-2 py-1 rounded-md bg-violet-500/20 text-violet-300 text-xs font-medium border border-violet-500/20">
                    Digital Art
                  </span>
                  <span className="px-2 py-1 rounded-md bg-white/5 text-slate-400 text-xs font-medium border border-white/10">
                    #4281
                  </span>
                </div>
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-2">
                  {item.title}
                </h2>
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-gradient-to-r from-pink-500 to-orange-400 p-[1px]">
                    <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100&auto=format&fit=crop" className="w-full h-full rounded-full object-cover" alt="Artist" />
                  </div>
                  <div>
                    <p className="text-sm text-slate-400">Created by</p>
                    <p className="text-sm font-medium text-white hover:text-violet-400 cursor-pointer transition-colors">
                      {item.artist}
                    </p>
                  </div>
                </div>
              </div>

              {/* Bid Card */}
              <div className="p-6 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-sm">
                <div className="flex justify-between items-end mb-6">
                  <div>
                    <p className="text-sm text-slate-400 mb-1">Current Bid</p>
                    <div className="flex items-baseline gap-2">
                      <span className="text-3xl font-bold text-white">
                        {item.currentBid} ETH
                      </span>
                      <span className="text-sm text-slate-500">
                        (${(item.currentBid * 2400).toLocaleString()})
                      </span>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-slate-400 mb-1">
                      Auction Ends In
                    </p>
                    <div className="flex items-center gap-2 text-xl font-mono font-medium text-white">
                      <Clock className="w-5 h-5 text-violet-400" />
                      <span>
                        {item.timeLeft.hours}h {item.timeLeft.minutes}m{' '}
                        {item.timeLeft.seconds}s
                      </span>
                    </div>
                  </div>
                </div>

                <button className="w-full py-4 bg-gradient-primary rounded-xl text-white font-bold text-lg shadow-lg shadow-violet-500/25 hover:shadow-violet-500/40 hover:scale-[1.02] active:scale-[0.98] transition-all">
                  Place Bid
                </button>

                <p className="text-center text-xs text-slate-500 mt-4 flex items-center justify-center gap-1">
                  <ShieldCheck className="w-3 h-3" />
                  Secure transaction via Ethereum Network
                </p>
              </div>

              {/* History */}
              <div>
                <h3 className="text-lg font-bold text-white mb-4">
                  Bid History
                </h3>
                <div className="space-y-4">
                  {[1, 2, 3].map(bid => <div key={bid} className="flex items-center justify-between p-3 rounded-xl hover:bg-white/5 transition-colors">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-slate-800 flex items-center justify-center">
                          <User className="w-4 h-4 text-slate-400" />
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">
                            0x8a...4b2
                          </p>
                          <p className="text-xs text-slate-500">2 hours ago</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-1 text-violet-400 font-medium">
                        <TrendingUp className="w-3 h-3" />
                        {item.currentBid - bid * 0.2} ETH
                      </div>
                    </div>)}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </motion.div>;
}