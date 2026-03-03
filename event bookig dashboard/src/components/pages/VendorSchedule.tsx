import React from 'react';
import { motion } from 'motion/react';
import { useVendorBookings, Booking } from '../../hooks/useVendorBookings';

const VendorSchedule: React.FC = () => {
  const { bookings, loading, error } = useVendorBookings();

  if (error) {
    const isIndexError = error.toLowerCase().includes('index');
    return (
      <div className="p-8 bg-white dark:bg-slate-900 rounded-xl border border-red-200">
        <p className="text-red-500 font-bold mb-2">Error loading bookings</p>
        <p className="text-sm text-slate-600 dark:text-slate-400">{error}</p>
        {isIndexError && (
          <p className="text-sm text-amber-600 mt-3 font-medium">
            ⚠️ A Firestore composite index is required. Check the browser console for a link to create it automatically.
          </p>
        )}
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8"
    >
      <header className="mb-0">
        <h1 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Schedule & Time Slots</h1>
        <p className="text-slate-500 dark:text-slate-400 mt-1">View bookings made by your clients.</p>
      </header>

      <section className="mt-8">
        <div className="space-y-4">
          {loading ? (
            <p className="text-slate-500 italic">Loading bookings...</p>
          ) : bookings.map((booking, i) => (
            <div key={i} className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl p-5 hover:shadow-md transition-shadow">
              <div className="flex flex-wrap items-center gap-6">
                <div className="flex items-center gap-4 flex-1 min-w-[200px]">
                  <div className="bg-slate-100 dark:bg-slate-800 w-12 h-12 rounded-lg flex flex-col items-center justify-center text-slate-600 dark:text-slate-400">
                    <span className="material-symbols-outlined text-primary">event</span>
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-900 dark:text-white">{booking.event?.title || "Booking"}</h3>
                    <p className="text-sm text-slate-500 flex items-center gap-1">
                      <span className="material-symbols-outlined text-[16px]">calendar_month</span>
                      {booking.date?.toDate().toLocaleDateString()}
                    </p>
                    <p className="text-sm text-slate-500 flex items-center gap-1">
                      <span className="material-symbols-outlined text-[16px]">schedule</span>
                      {booking.timeSlot}
                    </p>
                  </div>
                </div>

                <div className="flex flex-col gap-1 min-w-[120px]">
                  <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider">Client Info</span>
                  <div className="flex flex-col">
                    <span className="text-sm font-medium text-slate-700 dark:text-slate-300">ID: {booking.clientId}</span>
                    <span className="text-xs text-slate-500">{booking.clientType}</span>
                  </div>
                </div>

                <div className="flex flex-col gap-1 min-w-[150px]">
                  <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider">Financials</span>
                  <div className="flex flex-col">
                    <span className="text-sm font-bold text-slate-900 dark:text-white">₹{Number(booking.totalAmount).toFixed(2)} <span className="text-[10px] text-slate-400 font-normal">Total</span></span>
                    <span className="text-xs font-semibold text-emerald-600">₹{Number(booking.advancePaid).toFixed(2)} <span className="text-[10px] text-slate-400 font-normal">Advance Paid</span></span>
                  </div>
                </div>

                <div className="flex items-center gap-4 ml-auto">
                  <span className="px-3 py-1 bg-primary/10 text-primary text-[11px] font-bold uppercase tracking-wide rounded-full">
                    {booking.clientType || 'individual'}
                  </span>
                </div>
              </div>
            </div>
          ))}

          {!loading && bookings.length === 0 && (
            <div className="text-center py-12 bg-white dark:bg-slate-900 rounded-2xl border border-dotted border-slate-300 dark:border-slate-800">
              <span className="material-symbols-outlined text-4xl text-slate-300 mb-2">event_busy</span>
              <p className="text-slate-500">No bookings yet.</p>
            </div>
          )}
        </div>
      </section>
    </motion.div>
  );
};

export default VendorSchedule;
