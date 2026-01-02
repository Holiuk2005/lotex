import React from 'react';
import { AuctionGrid } from './AuctionGrid';
// Reusing mock data structure for demo
const SAVED_ITEMS = [{
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
}];
export function FavoritesView() {
  return <div className="p-4 md:p-8">
      <h1 className="text-3xl font-bold text-white mb-2">Saved Auctions</h1>
      <p className="text-slate-400 mb-8">
        Keep track of the auctions you're interested in.
      </p>

      <AuctionGrid items={SAVED_ITEMS} />
    </div>;
}