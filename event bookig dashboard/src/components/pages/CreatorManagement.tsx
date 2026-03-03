import React, { useState, useMemo } from 'react';
import { motion } from 'motion/react';
import { useUsersByRole } from '../../hooks/useAdminData';
import { getInitials } from '../../lib/utils';

const CreatorManagement: React.FC = () => {
  const { users, loading, suspendUser, liftSuspension } = useUsersByRole('creator');
  const [searchTerm, setSearchTerm] = useState('');

  const handleSuspensionToggle = async (userId: string, isCurrentlySuspended: boolean) => {
    const action = isCurrentlySuspended ? 'Lift suspension?' : 'Suspend user for 7 days?';
    if (window.confirm(action)) {
      if (isCurrentlySuspended) {
        await liftSuspension(userId);
      } else {
        await suspendUser(userId);
      }
    }
  };

  const filteredUsers = useMemo(() => {
    if (!searchTerm.trim()) return users;

    return users.filter(user =>
      (user.email || '')
        .toLowerCase()
        .includes(searchTerm.toLowerCase())
    );
  }, [users, searchTerm]);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8"
    >
      <header className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">
            Creator Management
          </h2>
          <p className="text-slate-500 dark:text-slate-400 mt-1">
            Monitor and manage all registered creators on the platform.
          </p>
        </div>
      </header>

      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap gap-4 items-center">
          <div className="relative flex-1 min-w-[300px]">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
              search
            </span>
            <input
              className="w-full pl-10 pr-4 py-2 bg-slate-50 dark:bg-slate-800 border-none rounded-lg focus:ring-2 focus:ring-primary/20 text-sm"
              placeholder="Search by email..."
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 dark:bg-slate-800/50 text-slate-500 uppercase text-[10px] font-black tracking-widest">
              <tr>
                <th className="px-6 py-4">Creator ID</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Studio Items</th>
                <th className="px-6 py-4">Shop Items</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {filteredUsers.map((user) => {
                const isSuspended =
                  user.suspendedUntil && user.suspendedUntil > Date.now();

                return (
                  <tr
                    key={user.id}
                    className="hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors"
                  >
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold shrink-0">
                          {getInitials(user.name || user.email || user.id)}
                        </div>
                        <span className="font-bold text-slate-900 dark:text-white">
                          {user.email || user.id}
                        </span>
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      <span
                        className={`px-2 py-1 rounded text-[10px] font-black uppercase ${isSuspended
                          ? 'bg-rose-50 text-rose-600'
                          : 'bg-emerald-50 text-emerald-600'
                          }`}
                      >
                        {isSuspended ? 'Suspended' : 'Active'}
                      </span>
                    </td>

                    <td className="px-6 py-4 text-sm text-slate-500">
                      {(user.studio || []).length} items
                    </td>

                    <td className="px-6 py-4 text-sm text-slate-500">
                      {(user.shop || []).length} items
                    </td>

                    <td className="px-6 py-4 text-right">
                      <div className="flex justify-end">
                        <button
                          onClick={() =>
                            handleSuspensionToggle(user.id, isSuspended)
                          }
                          className={`p-2 rounded-lg transition-colors ${isSuspended
                            ? 'text-emerald-500 hover:bg-emerald-50'
                            : 'text-rose-500 hover:bg-rose-50'
                            }`}
                          title={isSuspended ? 'Lift Suspension' : 'Suspend 7 Days'}
                        >
                          <span className="material-symbols-outlined text-xl">
                            {isSuspended ? 'check_circle' : 'block'}
                          </span>
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </motion.div>
  );
};

export default CreatorManagement;