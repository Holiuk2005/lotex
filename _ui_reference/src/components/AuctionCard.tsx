import React from 'react';
import { motion } from 'framer-motion';
import { Clock, Heart, TrendingUp } from 'lucide-react';
interface AuctionCardProps {
  id: string;
  title: string;
  artist: string;
  currentBid: number;
  image: string;
  timeLeft: {
    hours: number;
    minutes: number;
    seconds: number;
  };
  progress: number; // 0 to 100
}
export function AuctionCard({
  title,
  artist,
  currentBid,
  image,
  timeLeft,
  progress
}: AuctionCardProps) {
  // Calculate circumference for progress ring
  const radius = 18;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - progress / 100 * circumference;
  return <motion.div layout initial={{
    opacity: 0,
    y: 20
  }} animate={{
    opacity: 1,
    y: 0
  }} whileHover={{
    y: -8,
    scale: 1.02
  }} transition={{
    type: 'spring',
    stiffness: 300,
    damping: 20
  }} className="group relative bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl overflow-hidden shadow-xl hover:shadow-purple-500/20 hover:border-purple-500/30 transition-colors duration-300">
      {/* Image Container */}
      <div className="relative aspect-[4/3] overflow-hidden">
        <motion.img whileHover={{
        scale: 1.1
      }} transition={{
        duration: 0.6
      }} src={image} alt={title} className="w-full h-full object-cover" />

        {/* Overlay Gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-transparent to-transparent opacity-60" />

        {/* Floating Badge */}
        <div className="absolute top-3 right-3 bg-black/40 backdrop-blur-md border border-white/10 rounded-full px-3 py-1 flex items-center gap-1.5">
          <div className="relative w-2 h-2">
            <span className="absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75 animate-ping"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
          </div>
          <span className="text-xs font-medium text-white">Live</span>
        </div>
      </div>

      {/* Content */}
      <div className="p-5 space-y-4">
        <div className="flex justify-between items-start">
          <div>
            <h3 className="text-lg font-bold text-white leading-tight group-hover:text-purple-300 transition-colors">
              {title}
            </h3>
            <p className="text-sm text-slate-400">{artist}</p>
          </div>
          <button className="text-slate-400 hover:text-pink-500 transition-colors">
            <Heart className="w-5 h-5" />
          </button>
        </div>

        {/* Bid Info & Timer */}
        <div className="flex items-end justify-between">
          <div className="space-y-1">
            <p className="text-xs text-slate-400 font-medium uppercase tracking-wider">
              Current Bid
            </p>
            <div className="flex items-center gap-2">
              <TrendingUp className="w-4 h-4 text-green-400" />
              <span className="text-xl font-bold text-white">
                {currentBid} ETH
              </span>
            </div>
          </div>

          {/* Circular Timer */}
          <div className="flex items-center gap-3 bg-white/5 rounded-full pl-1 pr-3 py-1 border border-white/5">
            <div className="relative w-10 h-10 flex items-center justify-center">
              <svg className="transform -rotate-90 w-10 h-10">
                <circle cx="20" cy="20" r={radius} stroke="currentColor" strokeWidth="3" fill="transparent" className="text-slate-700" />
                <motion.circle initial={{
                strokeDashoffset: circumference
              }} animate={{
                strokeDashoffset
              }} transition={{
                duration: 1,
                ease: 'easeOut'
              }} cx="20" cy="20" r={radius} stroke="currentColor" strokeWidth="3" fill="transparent" strokeDasharray={circumference} strokeLinecap="round" className="text-purple-500" />
              </svg>
              <Clock className="w-4 h-4 text-white absolute" />
            </div>
            <div className="text-right">
              <p className="text-xs text-slate-400">Ending in</p>
              <p className="text-sm font-mono font-medium text-white">
                {timeLeft.hours}h {timeLeft.minutes}m
              </p>
            </div>
          </div>
        </div>

        {/* Action Button */}
        <motion.button whileHover={{
        scale: 1.02
      }} whileTap={{
        scale: 0.98
      }} className="w-full py-2.5 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl text-white font-semibold text-sm shadow-lg shadow-purple-500/25 opacity-100 md:opacity-0 group-hover:opacity-100 transition-opacity duration-200">
          Place Bid
        </motion.button>
      </div>
    </motion.div>;
}