import React from 'react';
import { Settings, Edit2, Grid, Award, Clock, TrendingUp } from 'lucide-react';
export function ProfileView() {
  return <div className="flex-1 bg-slate-950 min-h-full">
      {/* Header Banner */}
      <div className="h-48 bg-gradient-to-r from-violet-900 to-blue-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20"></div>
        <div className="absolute inset-0 bg-gradient-to-t from-slate-950 to-transparent"></div>
      </div>

      <div className="px-4 md:px-8 -mt-20 relative z-10 max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row items-start md:items-end justify-between gap-6 mb-8">
          <div className="flex items-end gap-6">
            <div className="w-32 h-32 rounded-2xl bg-slate-900 p-1 border-4 border-slate-950 shadow-2xl">
              <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop" alt="Profile" className="w-full h-full rounded-xl object-cover" />
            </div>
            <div className="mb-2">
              <h1 className="text-3xl font-bold text-white">Sarah Connor</h1>
              <p className="text-slate-400">@sarah_c • Joined March 2024</p>
            </div>
          </div>

          <div className="flex gap-3 w-full md:w-auto">
            <button className="flex-1 md:flex-none px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2">
              <Settings className="w-4 h-4" />
              Settings
            </button>
            <button className="flex-1 md:flex-none px-4 py-2 bg-violet-600 hover:bg-violet-500 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2 shadow-lg shadow-violet-500/20">
              <Edit2 className="w-4 h-4" />
              Edit Profile
            </button>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
          {[{
          label: 'Total Volume',
          value: '142.5 ETH',
          icon: Grid
        }, {
          label: 'Items Collected',
          value: '24',
          icon: Award
        }, {
          label: 'Highest Bid',
          value: '12.4 ETH',
          icon: TrendingUp
        }, {
          label: 'Auctions Won',
          value: '18',
          icon: Clock
        }].map((stat, i) => <div key={i} className="p-4 rounded-xl bg-white/5 border border-white/10 backdrop-blur-sm">
              <p className="text-slate-400 text-xs mb-1">{stat.label}</p>
              <p className="text-xl font-bold text-white">{stat.value}</p>
            </div>)}
        </div>

        {/* Tabs */}
        <div className="border-b border-white/10 mb-8">
          <div className="flex gap-8">
            {['Collected', 'Created', 'Activity', 'Favorited'].map((tab, i) => <button key={tab} className={`pb-4 text-sm font-medium relative ${i === 0 ? 'text-white' : 'text-slate-500 hover:text-slate-300'}`}>
                {tab}
                {i === 0 && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-violet-500 shadow-[0_0_10px_rgba(139,92,246,0.5)]" />}
              </button>)}
          </div>
        </div>

        {/* Grid Placeholder */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 pb-20">
          {[1, 2, 3, 4, 5, 6].map(i => <div key={i} className="aspect-[4/3] rounded-xl bg-white/5 border border-white/10 animate-pulse" />)}
        </div>
      </div>
    </div>;
}