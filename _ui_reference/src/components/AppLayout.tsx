import React from 'react';
import { Sidebar } from './Sidebar';
import { BottomNav } from './BottomNav';
interface AppLayoutProps {
  children: React.ReactNode;
  activeTab: string;
  onTabChange: (tab: string) => void;
}
export function AppLayout({
  children,
  activeTab,
  onTabChange
}: AppLayoutProps) {
  return <div className="flex min-h-screen bg-white text-slate-900 font-sans">
      {/* Desktop Sidebar */}
      <Sidebar activeTab={activeTab} onTabChange={onTabChange} />

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col min-w-0 relative">{children}</main>

      {/* Mobile Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={onTabChange} />
    </div>;
}