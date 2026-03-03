import React from 'react';
import { motion } from 'motion/react';
import { useUserProfile } from '../hooks/useUserProfile';
import { getInitials } from '../lib/utils';

interface SidebarProps {
  role: 'vendor' | 'admin';
  activePage: string;
  onPageChange: (page: string) => void;
  onLogout: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ role, activePage, onPageChange, onLogout }) => {
  const { profile, user } = useUserProfile();

  const vendorLinks = [
    { id: 'home', label: 'Home', icon: 'home' },
    { id: 'studio', label: 'Studio', icon: 'video_camera_front' },
    { id: 'shop', label: 'Shop', icon: 'storefront' },
    { id: 'schedule', label: 'Schedule', icon: 'calendar_today' },
    { id: 'hr', label: 'HR', icon: 'badge' },
    { id: 'rates', label: 'Rates', icon: 'payments' },
    { id: 'support', label: 'Support', icon: 'support_agent' },
    { id: 'settings', label: 'Settings', icon: 'settings' },
  ];

  const adminLinks = [
    { id: 'admin-dashboard', label: 'Dashboard', icon: 'grid_view' },
    { id: 'creators', label: 'Creators', icon: 'group' },
    { id: 'vendors', label: 'Vendors', icon: 'storefront' },
    { id: 'transactions', label: 'Transactions', icon: 'receipt_long' },
    { id: 'reports', label: 'Reports', icon: 'flag' },
    { id: 'admin-settings', label: 'Settings', icon: 'settings' },
  ];

  const links = role === 'vendor' ? vendorLinks : adminLinks;

  return (
    <aside className="w-72 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col fixed h-full z-10">
      <div className="p-6 flex items-center gap-3">
        <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center text-white">
          <span className="material-symbols-outlined text-2xl">
            {role === 'vendor' ? 'construction' : 'shield_person'}
          </span>
        </div>
        <div>
          <h1 className="text-lg font-bold leading-none">
            {role === 'vendor' ? 'Portal' : 'Admin Panel'}
          </h1>
          <p className="text-xs text-slate-500 dark:text-slate-400 font-medium uppercase tracking-wider">
            {role === 'vendor' ? 'VENDOR' : 'MANAGEMENT'}
          </p>
        </div>
      </div>

      <nav className="flex-1 px-4 space-y-1 overflow-y-auto mt-4">
        {links.map((link) => (
          <button
            key={link.id}
            onClick={() => onPageChange(link.id)}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all group ${activePage === link.id
              ? 'bg-primary/10 text-primary'
              : 'text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800'
              }`}
          >
            <span className={`material-symbols-outlined ${activePage === link.id ? 'fill-1' : ''}`}>
              {link.icon}
            </span>
            <span className="text-sm font-semibold">{link.label}</span>
          </button>
        ))}
      </nav>

      <div className="p-4 border-t border-slate-200 dark:border-slate-800">
        <div className="flex items-center gap-3 mb-4 p-2">
          <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white shrink-0 font-bold">
            {getInitials(profile?.name || user?.displayName || 'User')}
          </div>
          <div className="overflow-hidden">
            <p className="text-sm font-bold truncate">{profile?.name || 'User'}</p>
            <p className="text-xs text-slate-500 truncate capitalize">{profile?.shopName || profile?.role || 'Account Manager'}</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="w-full flex items-center justify-center gap-2 px-4 py-2 border border-slate-200 dark:border-slate-800 rounded-lg text-sm font-semibold text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
        >
          <span className="material-symbols-outlined text-sm">logout</span>
          Logout
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
