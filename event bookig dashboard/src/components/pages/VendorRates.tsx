import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useVendorData } from '../../hooks/useVendorData';

const VendorRates: React.FC = () => {
  const { items, addItem, deleteItem } = useVendorData('rate');
  const [newService, setNewService] = useState('');
  const [newPrice, setNewPrice] = useState('');

  const handleUpdate = async () => {
    if (!newService || !newPrice) return;
    await addItem({
      name: newService,
      price: newPrice,
      description: 'Custom service rate',
      icon: 'payments',
      unit: 'per day'
    });
    setNewService('');
    setNewPrice('');
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 max-w-4xl mx-auto"
    >
      <header className="mb-10">
        <h1 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Service Rates</h1>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Manage your service pricing and rates effortlessly.</p>
      </header>

      <section className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl shadow-sm mb-12 p-6">
        <h2 className="text-lg font-bold mb-6 text-slate-800 dark:text-slate-100 flex items-center gap-2">
          <span className="material-symbols-outlined text-primary">add_circle</span>
          Add or Update Service
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
          <div className="md:col-span-1">
            <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">Service Name</label>
            <input
              value={newService}
              onChange={(e) => setNewService(e.target.value)}
              className="w-full rounded-lg border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-background-dark/30 focus:border-primary focus:ring-primary h-12 text-sm"
              placeholder="e.g. Studio Rental"
              type="text"
            />
          </div>
          <div className="md:col-span-1">
            <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">Price (₹)</label>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">₹</span>
              <input
                value={newPrice}
                onChange={(e) => setNewPrice(e.target.value)}
                className="w-full rounded-lg border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-background-dark/30 focus:border-primary focus:ring-primary h-12 pl-8 text-sm"
                placeholder="0.00"
                type="number"
              />
            </div>
          </div>
          <div className="md:col-span-1">
            <button
              onClick={handleUpdate}
              className="w-full h-12 bg-primary hover:bg-primary/90 text-white font-bold rounded-lg transition-all shadow-lg shadow-primary/20 flex items-center justify-center gap-2"
            >
              <span className="material-symbols-outlined text-[20px]">save</span>
              Add Rate
            </button>
          </div>
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-xl font-bold text-slate-900 dark:text-white">Active Services</h3>
          <span className="text-xs font-medium px-2 py-1 bg-slate-100 dark:bg-slate-800 rounded text-slate-500">{items.length} Services Total</span>
        </div>
        <div className="space-y-4">
          {items.map((rate, i) => (
            <div key={i} className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl p-5 flex items-center justify-between group hover:border-primary/30 transition-all shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-lg bg-primary/5 flex items-center justify-center text-primary">
                  <span className="material-symbols-outlined">{rate.icon || 'payments'}</span>
                </div>
                <div>
                  <h4 className="font-bold text-slate-900 dark:text-white capitalize">{rate.name}</h4>
                  <p className="text-xs text-slate-500">{rate.description}</p>
                </div>
              </div>
              <div className="flex items-center gap-8">
                <div className="text-right">
                  <span className="text-2xl font-black text-slate-900 dark:text-white">₹{rate.price}</span>
                  <span className="text-xs text-slate-400 block">{rate.unit}</span>
                </div>
                <div className="flex items-center gap-2">
                  <button className="p-2 text-slate-400 hover:text-primary hover:bg-primary/10 rounded-lg transition-all">
                    <span className="material-symbols-outlined text-[20px]">edit</span>
                  </button>
                  <button
                    onClick={() => deleteItem(i)}
                    className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                  >
                    <span className="material-symbols-outlined text-[20px]">delete</span>
                  </button>
                </div>
              </div>
            </div>
          ))}
          {items.length === 0 && (
            <div className="bg-slate-50 dark:bg-slate-800/50 border-2 border-dashed border-slate-200 dark:border-slate-800 rounded-xl p-12 flex flex-col items-center justify-center text-slate-400">
              <span className="material-symbols-outlined text-4xl mb-2">payments</span>
              <p className="font-medium">No services listed yet</p>
            </div>
          )}
        </div>
      </section>
    </motion.div>
  );
};

export default VendorRates;
