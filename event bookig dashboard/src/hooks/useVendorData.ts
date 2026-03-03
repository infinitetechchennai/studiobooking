import { useState, useEffect } from 'react';
import { auth, db } from '../lib/firebase';
import {
    doc,
    onSnapshot,
    updateDoc,
    arrayUnion,
    setDoc,
    getDoc
} from 'firebase/firestore';

export interface VendorItem {
    id?: string;
    [key: string]: any;
}

export function useVendorData(category: string) {
    const [items, setItems] = useState<VendorItem[]>([]);
    const [loading, setLoading] = useState(true);
    const user = auth.currentUser;

    useEffect(() => {
        if (!user) {
            setItems([]);
            setLoading(false);
            return;
        }

        const vendorRef = doc(db, "vendor_content", user.uid);
        const unsubscribe = onSnapshot(vendorRef, (snap) => {
            if (snap.exists()) {
                const data = snap.data();
                setItems(data[category] || []);
            } else {
                setItems([]);
            }
            setLoading(false);
        });

        return () => unsubscribe();
    }, [user, category]);

    const addItem = async (item: VendorItem) => {
        if (!user) return;
        const vendorRef = doc(db, "vendor_content", user.uid);
        const snap = await getDoc(vendorRef);

        if (!snap.exists()) {
            await setDoc(vendorRef, {
                userId: user.uid,
                [category]: [item],
                createdAt: Date.now(),
                updatedAt: Date.now(),
            });
        } else {
            await updateDoc(vendorRef, {
                [category]: arrayUnion(item),
                updatedAt: Date.now(),
            });
        }
    };

    const updateItems = async (newItems: VendorItem[]) => {
        if (!user) return;
        const vendorRef = doc(db, "vendor_content", user.uid);
        await updateDoc(vendorRef, {
            [category]: newItems,
            updatedAt: Date.now(),
        });
    };

    const deleteItem = async (index: number) => {
        const newItems = [...items];
        newItems.splice(index, 1);
        await updateItems(newItems);
    };

    const editItem = async (index: number, updatedItem: VendorItem) => {
        const newItems = [...items];
        newItems[index] = updatedItem;
        await updateItems(newItems);
    };

    return { items, loading, addItem, deleteItem, editItem };
}
