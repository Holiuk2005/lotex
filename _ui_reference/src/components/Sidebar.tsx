import React from 'react';
import { Home, Heart, MessageSquare, User, Settings, LogOut, Gavel, Plus } from 'lucide-react';
import { motion } from 'framer-motion';
interface SidebarProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}
export function Sidebar({
  activeTab,
  onTabChange
}: SidebarProps) {
  const menuItems = [{
    id: 'home',
    icon: Home,
    label: 'Marketplace'
  }, {
    id: 'favorites',
    icon: Heart,
    label: 'Favorites'
  }, {
    id: 'sell',
    icon: Plus,
    label: 'Sell Item'
  }, {
    id: 'chat',
    icon: MessageSquare,
    label: 'Messages'
  }, {
    id: 'profile',
    icon: User,
    label: 'Profile'
  }];
  const bottomItems = [{
    id: 'settings',
    icon: Settings,
    label: 'Settings'
  }, {
    id: 'logout',
    icon: LogOut,
    label: 'Log Out'
  }];
  return <aside className="hidden md:flex flex-col w-64 h-screen sticky top-0 bg-slate-950/50 backdrop-blur-xl border-r border-white/10 pt-6 pb-8 px-4">
      {/* Logo */}
      <div className="flex items-center gap-3 px-4 mb-10">
        <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center shadow-glow">
          <Gavel className="w-5 h-5 text-white" />
        </div>
        <span className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-slate-400">
          Lotex
        </span>
      </div>

      {/* Main Navigation */}
      <nav className="flex-1 space-y-2">
        {menuItems.map(item => {
        const isActive = activeTab === item.id;
        return <button key={item.id} onClick={() => onTabChange(item.id)} className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group relative overflow-hidden ${isActive ? 'text-white bg-white/10 shadow-lg shadow-purple-500/10' : 'text-slate-400 hover:text-white hover:bg-white/5'}`}>
              {isActive && <motion.div layoutId="sidebarActive" className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-violet-500 to-blue-500" />}
              <item.icon className={`w-5 h-5 ${isActive ? 'text-violet-400' : 'group-hover:text-violet-400 transition-colors'}`} />
              <span className="font-medium">{item.label}</span>
            </button>;
      })}
      </nav>

      {/* User Balance Card */}
      <div className="mt-auto mb-6 p-4 rounded-2xl bg-gradient-to-br from-slate-900 to-slate-800 border border-white/10 relative overflow-hidden group">
        <div className="absolute inset-0 bg-gradient-primary opacity-0 group-hover:opacity-10 transition-opacity duration-300" />
        <p className="text-xs text-slate-400 mb-1">Current Balance</p>
        <h3 className="text-xl font-bold text-white">24.5 ETH</h3>
        <div className="flex items-center gap-2 mt-2 text-xs text-green-400">
          <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
          <span>+2.4% this week</span>
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="space-y-1 pt-4 border-t border-white/10">
        {bottomItems.map(item => <button key={item.id} className="w-full flex items-center gap-3 px-4 py-2.5 rounded-lg text-slate-500 hover:text-white hover:bg-white/5 transition-colors text-sm font-medium">
            <item.icon className="w-4 h-4" />
            <span>{item.label}</span>
          </button>)}
      </div>
    </aside>;
}