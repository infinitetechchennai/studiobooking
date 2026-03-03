import { useState, useEffect } from 'react';
import { auth, db } from '../lib/firebase';
import { doc, onSnapshot } from 'firebase/firestore';
import { UserProfile } from '../types';

export function useUserProfile() {
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const user = auth.currentUser;

    useEffect(() => {
        if (!user) {
            setProfile(null);
            setLoading(false);
            return;
        }

        const userRef = doc(db, "users", user.uid);
        const unsubscribe = onSnapshot(userRef, (snap) => {
            if (snap.exists()) {
                setProfile({ uid: snap.id, ...snap.data() } as UserProfile);
            } else {
                setProfile(null);
            }
            setLoading(false);
        }, (err) => {
            console.error("Error fetching user profile:", err);
            setError(err.message);
            setLoading(false);
        });

        return () => unsubscribe();
    }, [user]);

    return { profile, loading, error, user };
}
