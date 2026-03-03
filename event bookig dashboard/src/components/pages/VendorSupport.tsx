import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useVendorData } from '../../hooks/useVendorData';

const VendorSupport: React.FC = () => {
  const { addItem } = useVendorData('reports');
  const [category, setCategory] = useState('');
  const [urgency, setUrgency] = useState('Normal');
  const [description, setDescription] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!category || !description) return;
    setIsSubmitting(true);
    try {
      await addItem({
        category,
        urgency,
        description,
        status: 'Open',
        createdAt: new Date().toISOString()
      });
      setCategory('');
      setDescription('');
      alert('Report submitted successfully!');
    } catch (error) {
      console.error(error);
      alert('Failed to submit report.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 max-w-4xl mx-auto"
    >
      <header className="mb-10">
        <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight mb-2">Report an Issue</h2>
        <p className="text-slate-500 dark:text-slate-400 text-lg">Submit a complaint or report an issue to the Admin team.</p>
      </header>

      <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden">
        <form onSubmit={handleSubmit} className="p-8 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">Issue Category</label>
              <div className="relative">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  required
                  className="w-full appearance-none bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg py-3 px-4 text-slate-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary outline-none transition-all"
                >
                  <option value="" disabled>Select a category</option>
                  <option value="technical">Technical Bug</option>
                  <option value="billing">Billing & Payments</option>
                  <option value="account">Account Access</option>
                  <option value="studio">Studio Equipment</option>
                  <option value="other">Other</option>
                </select>
                <div className="absolute inset-y-0 right-0 flex items-center px-3 pointer-events-none text-slate-400">
                  <span className="material-symbols-outlined">expand_more</span>
                </div>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">Urgency Level</label>
              <div className="flex gap-4">
                <label className="flex-1 cursor-pointer">
                  <input
                    checked={urgency === 'Normal'}
                    onChange={() => setUrgency('Normal')}
                    className="hidden peer"
                    name="urgency"
                    type="radio"
                  />
                  <div className="py-3 px-4 text-center text-sm font-medium rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 peer-checked:bg-primary/10 peer-checked:border-primary peer-checked:text-primary transition-all">
                    Normal
                  </div>
                </label>
                <label className="flex-1 cursor-pointer">
                  <input
                    checked={urgency === 'Urgent'}
                    onChange={() => setUrgency('Urgent')}
                    className="hidden peer"
                    name="urgency"
                    type="radio"
                  />
                  <div className="py-3 px-4 text-center text-sm font-medium rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 peer-checked:bg-red-50 peer-checked:border-red-500 peer-checked:text-red-600 transition-all">
                    Urgent
                  </div>
                </label>
              </div>
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-4 px-4 text-slate-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary outline-none transition-all resize-none"
              placeholder="Describe the issue in detail..."
              rows={8}
            ></textarea>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">Attachments</label>
            <div className="border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-xl p-8 flex flex-col items-center justify-center bg-slate-50/50 dark:bg-slate-800/50 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer">
              <span className="material-symbols-outlined text-slate-400 text-4xl mb-2">cloud_upload</span>
              <p className="text-sm font-medium text-slate-600 dark:text-slate-400">Click to upload or drag and drop</p>
              <p className="text-xs text-slate-400 dark:text-slate-500 mt-1">PNG, JPG or PDF (max. 10MB)</p>
            </div>
          </div>
          <div className="pt-4 flex items-center justify-end gap-4">
            <button className="px-6 py-3 text-sm font-semibold text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors" type="button">
              Cancel
            </button>
            <button
              disabled={isSubmitting}
              className="px-8 py-3 bg-primary hover:bg-primary/90 text-white text-sm font-bold rounded-lg shadow-lg shadow-primary/20 transition-all flex items-center gap-2"
              type="submit"
            >
              {isSubmitting ? (
                <span className="animate-spin material-symbols-outlined text-base">sync</span>
              ) : (
                <span className="material-symbols-outlined text-base">send</span>
              )}
              {isSubmitting ? 'Submitting...' : 'Submit Report'}
            </button>
          </div>
        </form>
      </div>
    </motion.div>
  );
};

export default VendorSupport;
