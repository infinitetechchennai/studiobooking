import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useVendorData } from '../../hooks/useVendorData';

const VendorShop: React.FC = () => {
  const { items, addItem, deleteItem } = useVendorData('shop');
  const [newName, setNewName] = useState('');
  const [newPrice, setNewPrice] = useState('');

  const handleAdd = async () => {
    if (!newName || !newPrice) return;

    await addItem({
      name: newName,
      price: newPrice,
      description: 'Newly listed item',
      icon: 'shopping_bag',
      status: 'Live Available'
    });

    setNewName('');
    setNewPrice('');
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 lg:p-12 max-w-4xl mx-auto"
    >
      <header className="mb-8">
        <h2 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white leading-tight">
          Shop Management
        </h2>
        <p className="text-slate-500 dark:text-slate-400 mt-1 font-medium">
          Manage your products and listings.
        </p>
      </header>

      <section className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden mb-8">
        <div className="p-6">

          {/* Header */}
          <div className="flex flex-col gap-2 mb-6">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white">
              Add New Product
            </h3>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              Fill in the details below to list a new item in your shop.
            </p>
          </div>

          {/* Form Fields */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">
                Product Name
              </label>
              <input
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all text-sm"
                placeholder="Enter product name"
                type="text"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-2">
                Price (₹)
              </label>
              <input
                value={newPrice}
                onChange={(e) => setNewPrice(e.target.value)}
                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all text-sm"
                placeholder="0.00"
                type="number"
              />
            </div>
          </div>

          {/* Button */}
          <div className="mt-6 flex justify-end">
            <button
              onClick={handleAdd}
              className="bg-primary hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-lg shadow-md shadow-primary/20 transition-all flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">add</span>
              Add Product
            </button>
          </div>

        </div>
      </section>

      <div className="space-y-4">
        <h3 className="text-sm font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider px-2">
          Current Inventory
        </h3>

        {items.map((product, i) => (
          <div
            key={i}
            className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm flex items-center justify-between group hover:border-primary/30 transition-all"
          >
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-lg flex items-center justify-center bg-primary/10">
                <span className="material-symbols-outlined text-primary">
                  {product.icon || 'shopping_bag'}
                </span>
              </div>

              <div>
                <h4 className="font-bold text-slate-900 dark:text-white">
                  {product.name}
                </h4>
                <p className="text-sm text-slate-500 dark:text-slate-400">
                  {product.description}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-8">
              <div className="text-right">
                <span className="text-sm font-bold text-slate-900 dark:text-white">
                  ₹{product.price}
                </span>

                <p
                  className={`text-[10px] font-bold uppercase ${product.status === 'Live Available'
                      ? 'text-emerald-500'
                      : 'text-amber-500'
                    }`}
                >
                  {product.status}
                </p>
              </div>

              <button
                onClick={() => deleteItem(i)}
                className="p-2 text-rose-500 hover:bg-rose-50 rounded-lg transition-colors flex items-center gap-1 text-sm font-bold"
              >
                <span className="material-symbols-outlined text-lg">
                  delete
                </span>
                Delete
              </button>
            </div>
          </div>
        ))}

        {items.length === 0 && (
          <div className="border-2 border-dashed border-slate-200 dark:border-slate-800 rounded-xl p-8 flex flex-col items-center justify-center text-slate-400">
            <span className="material-symbols-outlined text-4xl mb-2">
              add_circle
            </span>
            <p className="text-sm font-medium">
              Add more items to grow your catalog
            </p>
          </div>
        )}
      </div>
    </motion.div>
  );
};

export default VendorShop;