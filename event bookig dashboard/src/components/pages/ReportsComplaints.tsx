import React from 'react';
import { motion } from 'motion/react';
import { useAdminData } from '../../hooks/useAdminData';

const ReportsComplaints: React.FC = () => {
  const { items: reports } = useAdminData('reports');

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 max-w-5xl mx-auto"
    >
      <header className="mb-8">
        <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Reports & Complaints</h2>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Review issues reported by users and vendors.</p>
      </header>

      <div className="space-y-6">
        {reports.map((report) => (
          <div key={report.id} className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
            <div className="p-6">
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400">
                    <span className="material-symbols-outlined">person</span>
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-900 dark:text-white">{report.fromEmail || 'Anonymous'}</h4>
                    <p className="text-xs text-slate-500 font-bold uppercase tracking-wider">{report.fromRole || 'User'}</p>
                  </div>
                </div>
              </div>
              <p className="text-slate-700 dark:text-slate-300 text-sm leading-relaxed mb-6">
                <span className="font-bold text-slate-900 dark:text-white block mb-1">Issue:</span>
                {report.message}
              </p>
              <div className="flex items-center justify-between pt-4 border-t border-slate-50 dark:border-slate-800">
                <span className="text-xs text-slate-400 font-medium">
                  {report.createdAt ? new Date(report.createdAt).toLocaleString() : 'N/A'}
                </span>
                <span className="text-[10px] font-bold px-2 py-1 rounded bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-100 dark:border-slate-700">
                  ID: {report.id.substring(0, 8)}
                </span>
              </div>
            </div>
          </div>
        ))}

        {reports.length === 0 && (
          <div className="text-center py-12 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800">
            <span className="material-symbols-outlined text-4xl text-slate-300 mb-2">task_alt</span>
            <p className="text-slate-500">No active reports found.</p>
          </div>
        )}
      </div>
    </motion.div>
  );
};

export default ReportsComplaints;
