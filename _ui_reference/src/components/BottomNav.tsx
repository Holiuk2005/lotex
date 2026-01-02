import React from 'react';
import { Home, Heart, MessageSquare, User, Plus } from 'lucide-react';
import { motion } from 'framer-motion';
interface BottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}
export function BottomNav({
  activeTab,
  onTabChange
}: BottomNavProps) {
  const items = [{
    id: 'home',
    icon: Home,
    label: 'Головна'
  }, {
    id: 'favorites',
    icon: Heart,
    label: 'Обране'
  }, {
    id: 'sell',
    icon: Plus,
    label: 'Продати',
    isAction: true
  }, {
    id: 'chat',
    icon: MessageSquare,
    label: 'Чат'
  }, {
    id: 'profile',
    icon: User,
    label: 'Профіль'
  }];
  return <div className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-slate-950/80 backdrop-blur-xl border-t border-white/10 pb-safe">
      <div className="flex items-end justify-between px-4 py-2">
        {items.map(item => {
        const isActive = activeTab === item.id;
        if (item.isAction) {
          return <button key={item.id} onClick={() => onTabChange(item.id)} className="relative -top-6 flex flex-col items-center justify-center group">
                <div className="w-14 h-14 rounded-full bg-gradient-to-r from-violet-600 to-blue-600 text-white flex items-center justify-center shadow-lg shadow-violet-500/40 border border-white/20 transform transition-transform active:scale-95 group-hover:shadow-violet-500/60">
                  <Plus className="w-8 h-8" />
                </div>
                <span className="text-[10px] font-medium text-slate-400 mt-1 group-hover:text-white transition-colors">
                  {item.label}
                </span>
              </button>;
        }
        return <button key={item.id} onClick={() => onTabChange(item.id)} className="relative flex flex-col items-center gap-1 min-w-[60px] py-1">
              {isActive && <motion.div layoutId="bottomNavActive" className="absolute -top-3 w-8 h-1 bg-gradient-to-r from-violet-500 to-blue-500 rounded-full shadow-[0_0_10px_rgba(139,92,246,0.5)]" />}
              <item.icon className={`w-6 h-6 transition-colors ${isActive ? 'text-white' : 'text-slate-500'}`} />
              <span className={`text-[10px] font-medium transition-colors ${isActive ? 'text-white' : 'text-slate-500'}`}>
                {item.label}
              </span>
            </button>;
      })}
      </div>
    </div>;
}