import { useState, useEffect } from 'react';
import { db, auth } from '../lib/firebase';
import { collection, query, where, orderBy, onSnapshot } from 'firebase/firestore';

export interface Booking {
    id: string;
    creatorId: string;
    clientId: string;
    clientType?: string;
    date: any; // Firestore Timestamp
    timeSlot: string;
    totalAmount: number;
    advancePaid: number;
    event?: {
        title: string;
    };
    [key: string]: any;
}

export function useVendorBookings() {
    const [bookings, setBookings] = useState<Booking[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const user = auth.currentUser;

    useEffect(() => {
        if (!user) {
            setBookings([]);
            setLoading(false);
            return;
        }

        const q = query(
            collection(db, "bookings"),
            where("creatorId", "==", user.uid),
            orderBy("date", "desc"),
            orderBy("timeSlot", "desc")
        );

        const unsubscribe = onSnapshot(q, (snapshot) => {
            const data = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            })) as Booking[];
            setBookings(data);
            setLoading(false);
        }, (err) => {
            console.error("Error fetching bookings:", err);
            setError(err.message);
            setLoading(false);
        });

        return () => unsubscribe();
    }, [user]);

    return { bookings, loading, error };
}
