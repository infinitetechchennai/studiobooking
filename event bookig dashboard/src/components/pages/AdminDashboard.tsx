import React from 'react';
import { motion } from 'motion/react';
import { useAdminData, useUsersByRole } from '../../hooks/useAdminData';
import { getInitials } from '../../lib/utils';

const AdminDashboard: React.FC = () => {
  const { users: vendors } = useUsersByRole('vendor');
  const { items: reports } = useAdminData('reports');
  const { items: transactions } = useAdminData('transactions');

  // Simple aggregations
  const totalVendors = vendors.length;
  const totalRevenue = transactions.reduce((acc, tx) => acc + (tx.amount || 0), 0);
  const activeReports = reports.filter(r => r.status !== 'Resolved').length;

  const stats = [
    { label: 'Total Creators', val: '12,482', change: '+12%', icon: 'group', color: 'blue' },
    { label: 'Active Vendors', val: totalVendors.toString(), change: '+5%', icon: 'storefront', color: 'emerald' },
    { label: 'Platform Revenue', val: `₹${totalRevenue.toLocaleString()}`, change: '+18%', icon: 'payments', color: 'amber' },
    { label: 'Active Reports', val: activeReports.toString(), change: '-2', icon: 'flag', color: 'rose' },
  ];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 space-y-8"
    >
      <header className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Platform Overview</h2>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Real-time metrics and platform activity.</p>
        </div>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className={`w-12 h-12 rounded-xl bg-${stat.color}-50 dark:bg-${stat.color}-900/20 flex items-center justify-center text-${stat.color}-600`}>
                <span className="material-symbols-outlined text-2xl">{stat.icon}</span>
              </div>
            </div>
            <h4 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-1">{stat.label}</h4>
            <p className="text-3xl font-black text-slate-900 dark:text-white">{stat.val}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
          <div className="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
            <h3 className="font-bold text-lg">Recent Platform Activity</h3>
            <button className="text-sm font-bold text-primary hover:underline">View All</button>
          </div>
          <div className="p-6 space-y-6">
            {reports.slice(0, 4).map((report, i) => (
              <div key={i} className="flex gap-4">
                <div className={`w-10 h-10 rounded-full bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center text-blue-600 shrink-0`}>
                  <span className="material-symbols-outlined text-xl">report</span>
                </div>
                <div>
                  <p className="text-sm">
                    <span className="font-bold text-slate-900 dark:text-white">{report.from}</span>
                    <span className="text-slate-500 dark:text-slate-400 ml-1">submitted a report: {report.category}</span>
                  </p>
                  <p className="text-xs text-slate-400 mt-0.5">{new Date(report.createdAt).toLocaleString()}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
          <h3 className="font-bold text-lg mb-6">Top Performing Vendors</h3>
          <div className="space-y-6">
            {vendors.slice(0, 4).map((vendor, i) => (
              <div key={i} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-primary flex items-center justify-center text-white text-xs font-bold shrink-0">
                    {getInitials(vendor.name || vendor.email || vendor.id)}
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-900 dark:text-white truncate max-w-[150px]">
                      {vendor.name || vendor.email || 'Vendor'}
                    </h4>
                    <p className="text-xs text-emerald-600 font-bold">Active</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default AdminDashboard;
