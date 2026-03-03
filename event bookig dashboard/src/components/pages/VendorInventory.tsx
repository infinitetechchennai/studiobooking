import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useVendorData } from '../../hooks/useVendorData';

const VendorInventory: React.FC = () => {
  const { items, addItem, deleteItem } = useVendorData('studio');

  const [newTitle, setNewTitle] = useState('');
  const [newCategory, setNewCategory] = useState('');

  React.useEffect(() => {
    if (items.length > 0 && !newTitle) {
      setNewTitle(items[0].title || items[0].name || '');
    }
  }, [items]);

  const handleAdd = async () => {
    if (!newCategory || !newTitle) {
      alert("Fill all fields");
      return;
    }

    // SINGLE TITLE RULE
    if (items.length > 0) {
      const existingTitle = items[0].title || items[0].name;
      if (newTitle !== existingTitle) {
        alert("You can only use one title. All categories must use the same title.");
        return;
      }
    }

    const categoryExists = items.find(
      (item) => item.category === newCategory
    );

    if (categoryExists) {
      alert("This category is already assigned.");
      return;
    }

    const itemData = {
      title: newTitle,
      category: newCategory,
      status: 'Available',
      icon: 'camera_outdoor',
      updatedAt: Date.now()
    };

    await addItem(itemData);

    setNewCategory('');
  };

  const handleDelete = async (index: number) => {
    if (window.confirm("Are you sure you want to delete this item?")) {
      await deleteItem(index);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8"
    >
      <header className="mb-8">
        <h2 className="text-2xl font-black tracking-tight text-slate-900 dark:text-white">
          Studio & Equipment Rental
        </h2>
        <div className="flex items-center gap-4 mt-2">
          <span className="text-sm font-medium text-slate-500">
            Vendor ID: #SR-9921
          </span>
        </div>
      </header>

      <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-6 mb-8 shadow-sm">
        <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
          <span className="material-symbols-outlined text-primary">
            add_circle
          </span>
          Register New Equipment
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
          <div className="flex flex-col gap-2">
            <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              Select Category
            </label>
            <select
              value={newCategory}
              onChange={(e) => setNewCategory(e.target.value)}
              className="w-full h-12 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary outline-none transition-all"
            >
              <option value="">Select Category</option>
              <option value="CAMERA SHOP">CAMERA SHOP</option>
              <option value="CAMERA STUDIO">CAMERA STUDIO</option>
              <option value="CAMERA EQUIPMENT">CAMERA EQUIPMENT</option>
              <option value="CAMERA RENTAL">CAMERA RENTAL</option>
              <option value="PHOTOGRAPGHER">PHOTOGRAPGHER</option>
            </select>
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              Title
            </label>
            <input
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              className="w-full h-12 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary outline-none transition-all"
              placeholder="Enter equipment name"
              type="text"
            />
          </div>

          <div className="flex gap-2">
            <button
              onClick={handleAdd}
              className="w-full md:w-auto min-w-[120px] h-12 bg-primary hover:bg-primary/90 text-white rounded-lg font-bold text-sm shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">add</span>
              Add Item
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
        <div className="px-6 py-4 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
          <h3 className="text-lg font-bold">Equipment Inventory</h3>

          {/* Keeping search UI unchanged */}
          <div className="relative">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
              search
            </span>
            <input
              className="pl-10 pr-4 h-9 w-64 rounded-lg bg-slate-50 dark:bg-slate-800 border-none text-sm focus:ring-1 focus:ring-primary"
              placeholder="Search equipment..."
              type="text"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 dark:bg-slate-800/50 text-slate-500 text-xs font-bold uppercase tracking-wider">
              <tr>
                <th className="px-6 py-4">Name</th>
                <th className="px-6 py-4">Category</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {items.map((item, i) => (
                <tr
                  key={i}
                  className="hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors"
                >
                  <td className="px-6 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                        <span className="material-symbols-outlined text-slate-400">
                          {item.icon || 'camera_outdoor'}
                        </span>
                      </div>
                      <span className="font-semibold">
                        {item.title || item.name}
                      </span>
                    </div>
                  </td>

                  <td className="px-6 py-5">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary/10 text-primary">
                      {item.category}
                    </span>
                  </td>

                  <td className="px-6 py-5">
                    <span className={`flex items-center gap-1.5 text-xs font-medium ${item.status === 'Available'
                        ? 'text-emerald-600'
                        : 'text-amber-600'
                      }`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${item.status === 'Available'
                          ? 'bg-emerald-600'
                          : 'bg-amber-600'
                        }`}></span>
                      {item.status}
                    </span>
                  </td>

                  {/* Actions column preserved for layout stability */}
                  <td className="px-6 py-5 text-right">
                    <div className="flex justify-end gap-2">
                      <button
                        onClick={() => handleDelete(i)}
                        className="h-9 w-9 flex items-center justify-center rounded-lg border border-red-200 text-red-600 hover:bg-red-50 transition-colors"
                      >
                        <span className="material-symbols-outlined text-lg">
                          delete
                        </span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="px-6 py-4 border-t border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/20 flex items-center justify-between">
          <p className="text-sm text-slate-500">
            Showing {items.length} equipment items
          </p>
        </div>
      </div>
    </motion.div>
  );
};

export default VendorInventory;