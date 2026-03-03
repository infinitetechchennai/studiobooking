import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { auth, db } from '../../lib/firebase';
import { doc, updateDoc, deleteDoc, collection, query, where, getDocs, writeBatch } from 'firebase/firestore';
import { deleteUser } from 'firebase/auth';
import { UserProfile } from '../../types';
import { useUserProfile } from '../../hooks/useUserProfile';
import { getInitials } from '../../lib/utils';

const AccountSettings: React.FC = () => {
  const { profile, loading, user } = useUserProfile();
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  // Form states
  const [name, setname] = useState('');
  const [shopName, setShopName] = useState('');
  const [bio, setBio] = useState('');

  useEffect(() => {
    if (profile) {
      setname(profile.name || user?.displayName || '');
      setShopName(profile.shopName || '');
      setBio(profile.bio || '');
    }
  }, [profile, user]);

  const handleDeleteAccount = async () => {
    if (!user || !profile) return;

    const confirmDelete = window.confirm(
      "Are you absolutely sure? This will permanently delete your account, all your listings, and all your data. This action cannot be undone."
    );

    if (!confirmDelete) return;

    setSaving(true);
    setMessage({ type: '', text: '' });

    try {
      const batch = writeBatch(db);

      // 1. Delete creator_listings
      const listingsQuery = query(collection(db, 'creator_listings'), where('ownerUserId', '==', user.uid));
      const listingsSnap = await getDocs(listingsQuery);
      listingsSnap.forEach((d) => batch.delete(d.ref));

      // 2. Delete listing_availability
      const availabilityQuery = query(collection(db, 'listing_availability'), where('ownerId', '==', user.uid));
      const availabilitySnap = await getDocs(availabilityQuery);
      availabilitySnap.forEach((d) => batch.delete(d.ref));

      // 3. Delete Vendor Content if they are a vendor
      if (profile.role === 'vendor') {
        const vendorDoc = doc(db, 'vendor_content', user.uid);
        batch.delete(vendorDoc);
      }

      // 4. Delete User Document
      batch.delete(doc(db, 'users', user.uid));

      // Commit all Firestore deletions
      await batch.commit();

      // 5. Delete Auth User (MUST BE LAST)
      // This will trigger the auth onAuthStateChanged in App.tsx
      await deleteUser(user);

    } catch (error: any) {
      console.error("Error deleting account:", error);
      if (error.code === 'auth/requires-recent-login') {
        setMessage({
          type: 'error',
          text: 'For security, please log out and log back in before deleting your account.'
        });
      } else {
        setMessage({ type: 'error', text: 'Deletion failed: ' + error.message });
      }
    } finally {
      setSaving(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setSaving(true);
    setMessage({ type: '', text: '' });

    try {
      await updateDoc(doc(db, 'users', user.uid), {
        name,
        shopName,
        bio,
        updatedAt: Date.now()
      });
      setMessage({ type: 'success', text: 'Profile updated successfully!' });
    } catch (error: any) {
      console.error("Error updating profile:", error);
      setMessage({ type: 'error', text: 'Failed to update profile: ' + error.message });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[400px]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-8 max-w-3xl mx-auto"
    >
      <header className="mb-10">
        <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Account Settings</h2>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Update your personal information and profile details.</p>
      </header>

      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
        <div className="p-8 border-b border-slate-100 dark:border-slate-800 flex items-center gap-6">
          <div className="relative group">
            <div className="w-24 h-24 rounded-full bg-primary flex items-center justify-center text-white text-3xl font-black border-4 border-white dark:border-slate-800 shadow-lg">
              {getInitials(profile?.name || user?.displayName || 'User')}
            </div>
          </div>
          <div>
            <h3 className="text-xl font-bold text-slate-900 dark:text-white">{name || 'User'}</h3>
            <p className="text-sm text-slate-500">Member since {profile?.createdAt ? new Date(profile.createdAt).toLocaleDateString() : 'October 2023'}</p>
          </div>
        </div>

        <form className="p-8 space-y-6" onSubmit={handleSave}>
          {message.text && (
            <div className={`p-4 rounded-xl text-sm font-bold border ${message.type === 'success'
              ? 'bg-emerald-50 text-emerald-600 border-emerald-100 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-900/30'
              : 'bg-rose-50 text-rose-600 border-rose-100 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-900/30'
              }`}>
              {message.text}
            </div>
          )}

          <div className={`grid grid-cols-1 ${profile?.role === 'vendor' ? 'md:grid-cols-2' : ''} gap-6`}>
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 dark:text-slate-300">Full Name</label>
              <input
                className="w-full bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg h-12 px-4 focus:ring-2 focus:ring-primary outline-none transition-all"
                value={name}
                onChange={(e) => setname(e.target.value)}
                type="text"
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 dark:text-slate-300">Email Address</label>
              <input
                className="w-full bg-slate-200 dark:bg-slate-700 border-slate-200 dark:border-slate-600 rounded-lg h-12 px-4 text-slate-500 cursor-not-allowed transition-all"
                value={user?.email || ""}
                type="email"
                disabled
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 dark:text-slate-300">Role</label>
              <input
                className="w-full bg-slate-200 dark:bg-slate-700 border-slate-200 dark:border-slate-600 rounded-lg h-12 px-4 text-slate-500 cursor-not-allowed transition-all capitalize"
                value={profile?.role || ""}
                type="text"
                disabled
              />
            </div>
            {profile?.role === 'vendor' && (
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700 dark:text-slate-300">Shop Name</label>
                <input
                  className="w-full bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg h-12 px-4 focus:ring-2 focus:ring-primary outline-none transition-all"
                  value={shopName}
                  onChange={(e) => setShopName(e.target.value)}
                  type="text"
                />
              </div>
            )}
          </div>
          {profile?.role === 'vendor' && (
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 dark:text-slate-300">Bio</label>
              <textarea
                className="w-full bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-xl py-4 px-4 focus:ring-2 focus:ring-primary outline-none transition-all resize-none"
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={4}
              ></textarea>
            </div>
          )}
          <div className="pt-6 flex justify-end gap-4">
            <button
              className="px-6 py-3 text-sm font-bold text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-all"
              type="button"
              onClick={() => {
                setname(profile?.name || '');
                setShopName(profile?.shopName || '');
                setBio(profile?.bio || '');
              }}
            >
              Discard Changes
            </button>
            <button
              className="px-10 py-3 bg-primary text-white text-sm font-bold rounded-lg shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all disabled:opacity-50"
              type="submit"
              disabled={saving}
            >
              {saving ? 'Saving...' : 'Save Profile'}
            </button>
          </div>
        </form>
      </div>

      <div className="mt-8 bg-rose-50 dark:bg-rose-900/10 border border-rose-100 dark:border-rose-900/30 rounded-2xl p-6 flex items-center justify-between">
        <div>
          <h4 className="font-bold text-rose-600">Danger Zone</h4>
          <p className="text-sm text-rose-500/80">Permanently delete your account and all associated data.</p>
        </div>
        <button
          onClick={handleDeleteAccount}
          disabled={saving}
          className="px-6 py-2 bg-rose-600 text-white text-sm font-bold rounded-lg hover:bg-rose-700 transition-all disabled:opacity-50"
        >
          {saving ? 'Deleting...' : 'Delete Account'}
        </button>
      </div>
    </motion.div>
  );
};

export default AccountSettings;
