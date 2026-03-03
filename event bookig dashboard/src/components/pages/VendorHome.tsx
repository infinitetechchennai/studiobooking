import React from 'react';
import { motion } from 'motion/react';
import { useVendorData, VendorItem } from '../../hooks/useVendorData';
import { useVendorBookings } from '../../hooks/useVendorBookings';

interface VendorHomeProps {
  onPageChange: (page: string) => void;
}

const VendorHome: React.FC<VendorHomeProps> = ({ onPageChange }) => {
  const { items: studioItems } = useVendorData('studio');
  const { items: shopItems } = useVendorData('shop');
  const { items: staffItems } = useVendorData('staff');
  const { bookings } = useVendorBookings();

  const totalRevenue = bookings.reduce((acc, b) => acc + (Number(b.totalAmount) || 0), 0);
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 space-y-10"
    >
      <header>
        <div className="flex justify-between items-center mb-6">
          <div>
            <h2 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white">Welcome back, Team </h2>
            <p className="text-slate-500 dark:text-slate-400 mt-1">Here's what's happening with your studio and shop today.</p>
          </div>
          <div className="flex gap-3">


          </div>
        </div>
      </header>

      <section>
        <div className="flex items-center gap-2 mb-6">
          <span className="w-1 h-6 bg-primary rounded-full"></span>
          <h3 className="text-xl font-bold">Shortcuts & Management</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            { title: 'Manage Studio', desc: 'Rentals & Equipment lists', count: `${studioItems.length} Active Listings`, icon: 'camera_outdoor', color: 'primary', page: 'studio' },
            { title: 'My Shop', desc: 'Product listings & Sales', count: `${shopItems.length} items listed`, icon: 'shopping_bag', color: 'emerald', page: 'shop' },
            { title: 'Staff', desc: 'Manage your team', count: `${staffItems.length} Staff members`, icon: 'badge', color: 'amber', page: 'hr' },
          ].map((card, i) => (
            <div
              key={i}
              onClick={() => onPageChange(card.page)}
              className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 hover:shadow-xl hover:shadow-slate-200/50 dark:hover:shadow-none transition-all cursor-pointer group"
            >
              <div className={`w-12 h-12 bg-${card.color}-100 dark:bg-${card.color}-900/30 rounded-lg flex items-center justify-center text-${card.color}-600 mb-4 group-hover:bg-${card.color}-600 group-hover:text-white transition-colors`}>
                <span className="material-symbols-outlined text-2xl">{card.icon}</span>
              </div>
              <h4 className="text-lg font-bold mb-1">{card.title}</h4>
              <p className="text-sm text-slate-500 dark:text-slate-400 mb-4">{card.desc}</p>
              <div className="flex items-center justify-between pt-4 border-t border-slate-50 dark:border-slate-800">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">{card.count}</span>
                <span className={`material-symbols-outlined text-${card.color}-600`}>chevron_right</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section>
        <div className="flex items-center gap-2 mb-6">
          <span className="w-1 h-6 bg-primary rounded-full"></span>
          <h3 className="text-xl font-bold">Performance Overview</h3>
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="bg-white dark:bg-slate-900 p-8 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm relative overflow-hidden">
            <div className="relative z-10">
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-2">Monthly Revenue</p>
              <div className="flex items-end gap-4 mb-8">
                <h4 className="text-5xl font-black">₹{totalRevenue.toLocaleString()}</h4>
                <div className="flex items-center text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20 px-2 py-1 rounded-md text-sm font-bold mb-1">
                  <span className="material-symbols-outlined text-sm mr-1">trending_up</span>
                  Live
                </div>
              </div>
              <div className="flex gap-2 items-end h-24 mb-6">
                {[...Array(7)].map((_, i) => {
                  const bookingCount = bookings.length;
                  const randomVariations = [0.6, 1.4, 0.8, 1.2, 1.5, 0.5, 1];
                  // If no bookings, show small base bars, otherwise scale by booking count
                  const height = bookingCount === 0
                    ? (10 * randomVariations[i])
                    : Math.min(100, (bookingCount * 20 * randomVariations[i]));
                  return (
                    <div key={i} className={`flex-1 ${i === 6 ? 'bg-primary' : 'bg-primary/10'} rounded-t transition-all duration-700`} style={{ height: `${height}%` }}></div>
                  );
                })}
              </div>
              <p className="text-sm text-slate-500">Total revenue generated from your confirmed bookings.</p>
            </div>
            <div className="absolute top-0 right-0 p-8 opacity-10">
              <span className="material-symbols-outlined text-[120px] leading-none">account_balance_wallet</span>
            </div>
          </div>

          <div className="bg-white dark:bg-slate-900 p-8 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm flex flex-col justify-between">
            <div>
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-2">Setup Progress</p>
              <div className="flex items-baseline gap-2 mb-6">
                <h4 className="text-5xl font-black">{Math.min(100, (studioItems.length + shopItems.length + staffItems.length) * 10)}%</h4>
                <span className="text-slate-500 font-medium">overall completion</span>
              </div>
              <div className="space-y-4">
                {[
                  { label: 'Studio Listings', val: Math.min(100, studioItems.length * 20), color: 'primary' },
                  { label: 'Shop Inventory', val: Math.min(100, shopItems.length * 10), color: 'primary' },
                ].map((bar, i) => (
                  <div key={i}>
                    <div className="flex justify-between text-sm font-bold mb-1">
                      <span>{bar.label}</span>
                      <span>{bar.val}%</span>
                    </div>
                    <div className="w-full h-2 bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                      <div className={`h-full bg-${bar.color} rounded-full transition-all duration-500`} style={{ width: `${bar.val}%` }}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="mt-8 pt-6 border-t border-slate-100 dark:border-slate-800 flex justify-between items-center">
              <div className="flex -space-x-3">
                {[1, 2, 3].map((n) => (
                  <div key={n} className="w-10 h-10 rounded-full border-4 border-white dark:border-slate-900 bg-slate-200 overflow-hidden">
                    <img alt="Customer" src={`https://picsum.photos/seed/cust${n}/100/100`} />
                  </div>
                ))}
                <div className="w-10 h-10 rounded-full border-4 border-white dark:border-slate-900 bg-slate-100 flex items-center justify-center text-[10px] font-bold">+{staffItems.length}</div>
              </div>
              <button
                onClick={() => onPageChange('hr')}
                className="text-primary text-sm font-bold hover:underline"
              >
                View Team
              </button>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        <div className="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
          <h3 className="font-bold text-lg">Recent Equipment & Shop Status</h3>
          <div className="flex gap-2">
            <button onClick={() => onPageChange('shop')} className="text-xs font-bold text-emerald-600 hover:underline">View Shop</button>
            <button onClick={() => onPageChange('studio')} className="text-xs font-bold text-primary hover:underline">View Studio</button>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 dark:bg-slate-800/50 text-slate-500 uppercase text-xs font-black tracking-widest">
              <tr>
                <th className="px-6 py-4">Item Name</th>
                <th className="px-6 py-4">Source</th>
                <th className="px-6 py-4">Details</th>
                <th className="px-6 py-4">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {[
                ...studioItems.map(item => ({ ...item, source: 'Studio', displayTitle: item.title, displayDetail: item.category })),
                ...shopItems.map(item => ({ ...item, source: 'Shop', displayTitle: item.name, displayDetail: `₹${item.price}` }))
              ]
                .sort((a, b) => (b.updatedAt || 0) - (a.updatedAt || 0))
                .slice(0, 10)
                .map((item, i) => (
                  <tr key={i} className="hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <span className="material-symbols-outlined text-slate-400 text-lg">
                          {item.source === 'Shop' ? 'shopping_bag' : 'camera_outdoor'}
                        </span>
                        <span className="font-bold">{item.displayTitle}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`text-[10px] font-black px-2 py-0.5 rounded uppercase ${item.source === 'Shop' ? 'bg-emerald-50 text-emerald-600' : 'bg-primary/10 text-primary'}`}>
                        {item.source}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">{item.displayDetail}</td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 bg-emerald-50 text-emerald-600 dark:bg-emerald-900/20 text-[10px] font-black rounded uppercase`}>Live</span>
                    </td>
                  </tr>
                ))}
              {studioItems.length === 0 && shopItems.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-6 py-8 text-center text-slate-500">No items added yet.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </motion.div>
  );
};

export default VendorHome;

