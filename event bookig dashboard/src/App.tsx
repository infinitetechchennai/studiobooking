import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import VendorHome from './components/pages/VendorHome';
import VendorInventory from './components/pages/VendorInventory';
import VendorShop from './components/pages/VendorShop';
import VendorSchedule from './components/pages/VendorSchedule';
import VendorHR from './components/pages/VendorHR';
import VendorRates from './components/pages/VendorRates';
import VendorSupport from './components/pages/VendorSupport';
import AccountSettings from './components/pages/AccountSettings';
import AdminDashboard from './components/pages/AdminDashboard';
import CreatorManagement from './components/pages/CreatorManagement';
import VendorManagement from './components/pages/VendorManagement';
import Transactions from './components/pages/Transactions';
import ReportsComplaints from './components/pages/ReportsComplaints';
import Auth from './components/pages/Auth';
import { UserRole } from './types';
import { auth, db } from './lib/firebase';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

const App: React.FC = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [role, setRole] = useState<UserRole>('vendor');
  const [activePage, setActivePage] = useState('home');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const userDoc = await getDoc(doc(db, 'users', user.uid));
          if (userDoc.exists()) {
            const userData = userDoc.data();

            // Suspension check for persistent sessions
            if (userData.suspendedUntil && userData.suspendedUntil > Date.now()) {
              await signOut(auth);
              setIsAuthenticated(false);
              setLoading(false);
              return;
            }

            setRole(userData.role as UserRole);
            setIsAuthenticated(true);
            setActivePage(userData.role === 'admin' ? 'admin-dashboard' : 'home');
          } else {
            // Fallback for users without a profile doc
            setRole('vendor');
            setIsAuthenticated(true);
            setActivePage('home');
          }
        } catch (error) {
          console.error("Error fetching user role:", error);
          setIsAuthenticated(false);
        }
      } else {
        setIsAuthenticated(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleLogin = (userRole: UserRole) => {
    setRole(userRole);
    setIsAuthenticated(true);
    setActivePage(userRole === 'vendor' ? 'home' : 'admin-dashboard');
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
      setIsAuthenticated(false);
    } catch (error) {
      console.error("Logout error", error);
    }
  };

  const renderPage = () => {
    switch (activePage) {
      // Vendor Pages
      case 'home': return <VendorHome onPageChange={setActivePage} />;
      case 'studio': return <VendorInventory />;
      case 'shop': return <VendorShop />;
      case 'schedule': return <VendorSchedule />;
      case 'hr': return <VendorHR />;
      case 'rates': return <VendorRates />;
      case 'support': return <VendorSupport />;
      case 'settings': return <AccountSettings />;

      // Admin Pages
      case 'admin-dashboard': return <AdminDashboard />;
      case 'creators': return <CreatorManagement />;
      case 'vendors': return <VendorManagement />;
      case 'transactions': return <Transactions />;
      case 'reports': return <ReportsComplaints />;
      case 'admin-settings': return <AccountSettings />;

      default: return <VendorHome />;
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background-light dark:bg-background-dark">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Auth onLogin={handleLogin} />;
  }

  return (
    <div className="flex min-h-screen bg-background-light dark:bg-background-dark">
      <Sidebar
        role={role}
        activePage={activePage}
        onPageChange={setActivePage}
        onLogout={handleLogout}
      />
      <main className="flex-1 ml-72 min-h-screen overflow-y-auto">
        {renderPage()}
      </main>
    </div>
  );
};


export default App;
