import { useState, useEffect } from 'react';
import { db } from '../lib/firebase';
import { collection, onSnapshot, doc, updateDoc, query, where } from 'firebase/firestore';

export function useAdminData(collectionName: string) {
    const [items, setItems] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const colRef = collection(db, collectionName);
        const unsubscribe = onSnapshot(colRef, (snap) => {
            const data = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setItems(data);
            setLoading(false);
        }, (error) => {
            console.error(`Error fetching ${collectionName}:`, error);
            setLoading(false);
        });

        return () => unsubscribe();
    }, [collectionName]);

    return { items, loading };
}

export function useUsersByRole(role: 'creator' | 'vendor') {
    const [users, setUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const q = query(collection(db, 'users'), where('role', '==', role));
        const unsubscribe = onSnapshot(q, (snap) => {
            const data = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setUsers(data);
            setLoading(false);
        });

        return () => unsubscribe();
    }, [role]);

    const suspendUser = async (userId: string) => {
        try {
            const userRef = doc(db, 'users', userId);
            const sevenDays = 7 * 24 * 60 * 60 * 1000;
            await updateDoc(userRef, {
                suspendedUntil: Date.now() + sevenDays
            });
        } catch (error) {
            console.error('Error suspending user:', error);
            throw error;
        }
    };

    const liftSuspension = async (userId: string) => {
        try {
            const userRef = doc(db, 'users', userId);
            await updateDoc(userRef, {
                suspendedUntil: null
            });
        } catch (error) {
            console.error('Error lifting suspension:', error);
            throw error;
        }
    };

    return { users, loading, suspendUser, liftSuspension };
}

export function useAllVendors() {
    const [vendors, setVendors] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const colRef = collection(db, 'vendor_content');
        const unsubscribe = onSnapshot(colRef, (snap) => {
            const data = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setVendors(data);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    return { vendors, loading };
}
