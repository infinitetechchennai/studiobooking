import React from 'react';
import { motion } from 'motion/react';
import { useAdminData } from '../../hooks/useAdminData';

const Transactions: React.FC = () => {
  const { items: transactions } = useAdminData('transactions');

  const totalVolume = transactions.reduce((acc, tx) => acc + (tx.totalAmount || tx.amount || 0), 0);
  const pendingPayouts = transactions.reduce((acc, tx) => {
    return acc + (tx.remainingAmount || (tx.totalAmount ? tx.totalAmount - (tx.amount || 0) : 0));
  }, 0);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8"
    >
      <header className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Financial Transactions</h2>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Detailed history of all platform payments and payouts.</p>
        </div>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {[
          { label: 'Total Volume', val: `₹${totalVolume.toLocaleString()}`, icon: 'account_balance', color: 'blue' },
          { label: 'Pending Payouts', val: `₹${pendingPayouts.toLocaleString()}`, icon: 'pending_actions', color: 'amber' },
        ].map((stat, i) => (
          <div key={i} className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-4">
            <div className={`w-12 h-12 rounded-xl bg-${stat.color}-50 dark:bg-${stat.color}-900/20 flex items-center justify-center text-${stat.color}-600`}>
              <span className="material-symbols-outlined text-2xl">{stat.icon}</span>
            </div>
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">{stat.label}</p>
              <p className="text-2xl font-black text-slate-900 dark:text-white">{stat.val}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap gap-4 items-center justify-between">
          <div className="relative flex-1 max-md:min-w-full">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">search</span>
            <input className="w-full pl-10 pr-4 py-2 bg-slate-50 dark:bg-slate-800 border-none rounded-lg focus:ring-2 focus:ring-primary/20 text-sm" placeholder="Search by email or transaction ID..." type="text" />
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 dark:bg-slate-800/50 text-slate-500 uppercase text-[10px] font-black tracking-widest">
              <tr>
                <th className="px-6 py-4">Financials</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Client Email</th>
                <th className="px-6 py-4">Type</th>
                <th className="px-6 py-4">Timestamp</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {transactions.map((tx) => (
                <tr key={tx.id} className="hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex flex-col gap-1">
                      <div className="flex justify-between items-center max-w-[180px]">
                        <span className="text-[10px] text-slate-400 uppercase font-black tracking-tighter">Total</span>
                        <span className="text-sm font-black text-slate-900 dark:text-white">₹{Number(tx.totalAmount || tx.amount || 0).toFixed(2)}</span>
                      </div>
                      <div className="flex justify-between items-center max-w-[180px]">
                        <span className="text-[10px] text-slate-400 uppercase font-black tracking-tighter">Paid</span>
                        <span className="text-sm font-bold text-emerald-600">₹{Number(tx.amount || 0).toFixed(2)}</span>
                      </div>
                      <div className="flex justify-between items-center max-w-[180px] pt-1 border-t border-slate-100 dark:border-slate-800">
                        <span className="text-[10px] text-slate-400 uppercase font-black tracking-tighter">Balance</span>
                        <span className="text-sm font-black text-amber-600">₹{Number(tx.remainingAmount || (tx.totalAmount ? tx.totalAmount - (tx.amount || 0) : 0)).toFixed(2)}</span>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded text-[10px] font-black uppercase ${tx.status === 'Success' ? 'bg-emerald-50 text-emerald-600' :
                      tx.status === 'Pending' ? 'bg-amber-50 text-amber-600' :
                        'bg-rose-50 text-rose-600'
                      }`}>
                      {tx.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-500">{tx.userEmail || tx.clientEmail || 'N/A'}</td>
                  <td className="px-6 py-4 text-sm font-bold text-slate-600 dark:text-slate-400">{tx.type}</td>
                  <td className="px-6 py-4 text-sm text-slate-400">
                    {tx.createdAt
                      ? (typeof tx.createdAt.toDate === 'function'
                        ? tx.createdAt.toDate().toLocaleString()
                        : new Date(tx.createdAt).toLocaleString())
                      : 'N/A'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </motion.div>
  );
};

export default Transactions;
