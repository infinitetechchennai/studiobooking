import React, { useState } from 'react';
import { motion } from 'motion/react';
import { auth, db } from '../../lib/firebase';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithPopup,
  signOut
} from 'firebase/auth';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { UserRole } from '../../types';

interface AuthProps {
  onLogin: (role: UserRole) => void;
}

const Auth: React.FC<AuthProps> = ({ onLogin }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setname] = useState('');
  const [selectedRole, setSelectedRole] = useState<UserRole>('vendor');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      if (isLogin) {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        // Fetch user data from Firestore
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          const userData = userDoc.data();

          // Suspension check
          if (userData.suspendedUntil && userData.suspendedUntil > Date.now()) {
            await signOut(auth);
            throw new Error('This account is currently suspended and cannot access the dashboard.');
          }

          onLogin(userData.role as UserRole);
        } else {
          // Default for compatibility
          onLogin('vendor');
        }
      } else {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        // Save profile to Firestore
        await setDoc(doc(db, 'users', user.uid), {
          uid: user.uid,
          email: user.email,
          name: name,
          role: selectedRole,
          suspendedUntil: null,
          createdAt: Date.now()
        });

        onLogin(selectedRole);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setError('');
    const provider = new GoogleAuthProvider();
    try {
      const result = await signInWithPopup(auth, provider);
      const user = result.user;

      // For Google Sign-In, we might need to check if user exists or create one
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      if (userDoc.exists()) {
        const userData = userDoc.data();
        if (userData.suspendedUntil && userData.suspendedUntil > Date.now()) {
          await signOut(auth);
          throw new Error('This account is currently suspended and cannot access the dashboard.');
        }
        onLogin(userData.role as UserRole);
      } else {
        // Create default profile for first-time Google sign-ins
        await setDoc(doc(db, 'users', user.uid), {
          uid: user.uid,
          email: user.email,
          name: user.displayName || '',
          role: 'vendor', // Default role for Google login
          suspendedUntil: null,
          createdAt: Date.now()
        });
        onLogin('vendor');
      }
    } catch (err: any) {
      setError(err.message);
    }
  };

  return (
    <div className="min-h-screen bg-background-light dark:bg-background-dark flex items-center justify-center p-6">
      <div className="w-full max-w-[1000px] bg-white dark:bg-slate-900 rounded-[32px] shadow-2xl overflow-hidden flex flex-col md:flex-row min-h-[600px]">
        <div className="w-full md:w-1/2 bg-primary p-12 flex flex-col justify-between text-white relative overflow-hidden">
          <div className="relative z-10">
            <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center mb-8">
              <span className="material-symbols-outlined text-3xl">construction</span>
            </div>
            <h1 className="text-4xl font-black leading-tight mb-4">Studio & Equipment Portal</h1>
            <p className="text-white/70 text-lg font-medium max-w-xs">The ultimate management system for vendors and platform administrators.</p>
          </div>

          <div className="relative z-10">
            <div className="flex -space-x-3 mb-4">
              {[1, 2, 3, 4].map(n => (
                <img key={n} alt="User" className="w-10 h-10 rounded-full border-2 border-primary" src={`https://picsum.photos/seed/auth${n}/100/100`} />
              ))}
              <div className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md border-2 border-primary flex items-center justify-center text-[10px] font-bold">+500</div>
            </div>
            <p className="text-sm font-bold">Trusted by 500+ vendors worldwide</p>
          </div>

          {/* Decorative elements */}
          <div className="absolute -bottom-20 -right-20 w-80 h-80 bg-white/10 rounded-full blur-3xl"></div>
          <div className="absolute top-20 -left-20 w-60 h-60 bg-white/5 rounded-full blur-2xl"></div>
        </div>

        <div className="w-full md:w-1/2 p-12 flex flex-col justify-center">
          <motion.div
            key={isLogin ? 'login' : 'register'}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="max-w-sm mx-auto w-full"
          >
            <h2 className="text-3xl font-black text-slate-900 dark:text-white mb-2">
              {isLogin ? 'Welcome Back' : 'Create Account'}
            </h2>
            <p className="text-slate-500 dark:text-slate-400 mb-8 font-medium">
              {isLogin ? 'Enter your credentials to access your portal.' : 'Join our network of professional equipment vendors.'}
            </p>

            {error && (
              <div className="p-4 mb-6 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 text-sm font-bold rounded-xl border border-red-100 dark:border-red-900/30">
                {error}
              </div>
            )}

            <form className="space-y-5" onSubmit={handleSubmit}>
              {!isLogin && (
                <>
                  <div className="space-y-2">
                    <label className="text-xs font-black text-slate-400 uppercase tracking-widest">Full Name</label>
                    <input
                      className="w-full h-12 px-4 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                      placeholder="John Doe"
                      type="text"
                      value={name}
                      onChange={(e) => setname(e.target.value)}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-xs font-black text-slate-400 uppercase tracking-widest">Register As</label>
                    <div className="grid grid-cols-2 gap-3">
                      <button
                        type="button"
                        onClick={() => setSelectedRole('vendor')}
                        className={`h-12 rounded-xl text-sm font-bold transition-all border ${selectedRole === 'vendor'
                          ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                          : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:border-primary'
                          }`}
                      >
                        Vendor
                      </button>
                      <button
                        type="button"
                        onClick={() => setSelectedRole('admin')}
                        className={`h-12 rounded-xl text-sm font-bold transition-all border ${selectedRole === 'admin'
                          ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                          : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:border-primary'
                          }`}
                      >
                        Admin
                      </button>
                    </div>
                  </div>
                </>
              )}
              <div className="space-y-2">
                <label className="text-xs font-black text-slate-400 uppercase tracking-widest">Email Address</label>
                <input
                  className="w-full h-12 px-4 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                  placeholder="name@example.com"
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-black text-slate-400 uppercase tracking-widest">Password</label>
                <input
                  className="w-full h-12 px-4 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                  placeholder="••••••••"
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>

              {isLogin && (
                <div className="flex justify-end">
                  <button className="text-xs font-bold text-primary hover:underline" type="button">Forgot Password?</button>
                </div>
              )}

              <button
                className="w-full h-14 bg-primary hover:bg-primary/90 text-white font-black rounded-xl shadow-xl shadow-primary/20 transition-all transform active:scale-[0.98] disabled:opacity-50"
                type="submit"
                disabled={isLoading}
              >
                {isLoading ? 'Processing...' : (isLogin ? 'Sign In' : 'Create Account')}
              </button>

              <div className="relative py-4">
                <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-100 dark:border-slate-800"></div></div>
                <div className="relative flex justify-center text-xs uppercase font-bold text-slate-400"><span className="bg-white dark:bg-slate-900 px-2">Or continue with</span></div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <button
                  onClick={handleGoogleSignIn}
                  className="h-12 border border-slate-200 dark:border-slate-700 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all font-bold text-sm"
                  type="button"
                >
                  <img alt="Google" className="w-5 h-5" src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/google.svg" />
                  Google
                </button>
                <button
                  type="button"
                  className="h-12 border border-slate-200 dark:border-slate-700 rounded-xl flex items-center justify-center gap-2 opacity-50 cursor-not-allowed font-bold text-sm"
                  title="Direct Admin access disabled. Login as Admin instead."
                >
                  <span className="material-symbols-outlined text-xl">shield_person</span>
                  Direct
                </button>
              </div>
            </form>

            <p className="mt-8 text-center text-sm font-medium text-slate-500">
              {isLogin ? "Don't have an account?" : "Already have an account?"}
              <button
                onClick={() => setIsLogin(!isLogin)}
                className="ml-1 text-primary font-bold hover:underline"
              >
                {isLogin ? 'Sign up' : 'Sign in'}
              </button>
            </p>
          </motion.div>
        </div>
      </div>
    </div>
  );
};


export default Auth;
