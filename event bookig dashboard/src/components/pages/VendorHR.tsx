import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useVendorData } from '../../hooks/useVendorData';

const VendorHR: React.FC = () => {
  const { items, addItem, deleteItem } = useVendorData('staff');
  const [newName, setNewName] = useState('');
  const [newRole, setNewRole] = useState('');

  const handleAdd = async () => {
    if (!newName || !newRole) return;
    const initials = newName.split(' ').map(n => n[0]).join('').toUpperCase();
    await addItem({ name: newName, role: newRole, initials });
    setNewName('');
    setNewRole('');
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 max-w-6xl mx-auto w-full"
    >
      <header className="mb-10">
        <h2 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight">HR & Staffing</h2>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Manage your team and staff roles.</p>
      </header>

      <section className="mb-10 bg-white dark:bg-slate-900 p-6 rounded-xl border border-primary/10 shadow-sm">
        <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
          <span className="material-symbols-outlined text-primary">person_add</span>
          Add New Staff
        </h3>
        <div className="flex flex-wrap items-end gap-6">
          <div className="flex-1 min-w-[240px]">
            <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">Staff Name</label>
            <input
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              className="w-full bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg h-12 px-4 focus:ring-2 focus:ring-primary focus:border-primary transition-all"
              placeholder="e.g. John Doe"
              type="text"
            />
          </div>
          <div className="flex-1 min-w-[240px]">
            <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">Role</label>
            <input
              value={newRole}
              onChange={(e) => setNewRole(e.target.value)}
              className="w-full bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg h-12 px-4 focus:ring-2 focus:ring-primary focus:border-primary transition-all"
              placeholder="e.g. Studio Manager"
              type="text"
            />
          </div>
          <button
            onClick={handleAdd}
            className="bg-primary hover:bg-blue-700 text-white font-bold h-12 px-8 rounded-lg transition-all shadow-lg shadow-primary/20 flex items-center justify-center gap-2"
          >
            <span className="material-symbols-outlined text-base">add</span>
            Add
          </button>
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-bold">Current Staff Members</h3>
          <div className="flex items-center gap-2 text-sm text-slate-500">
            <span className="material-symbols-outlined text-sm">filter_list</span>
            <span>Showing {items.length} members</span>
          </div>
        </div>
        <div className="grid grid-cols-1 gap-4">
          {items.map((staff, i) => (
            <div key={i} className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-primary/5 hover:border-primary/20 transition-all flex items-center justify-between group shadow-sm">
              <div className="flex items-center gap-4">
                <div className="size-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-lg">
                  {staff.initials}
                </div>
                <div>
                  <h4 className="font-bold text-slate-900 dark:text-white">{staff.name}</h4>
                  <p className="text-sm text-slate-500 dark:text-slate-400">{staff.role}</p>
                </div>
              </div>
              <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                <button className="p-2 text-slate-400 hover:text-primary hover:bg-primary/5 rounded-lg transition-all" title="Edit Staff">
                  <span className="material-symbols-outlined text-[20px]">edit</span>
                </button>
                <button
                  onClick={() => deleteItem(i)}
                  className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-all"
                  title="Delete Staff"
                >
                  <span className="material-symbols-outlined text-[20px]">delete</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      </section>
    </motion.div>
  );
};

export default VendorHR;
