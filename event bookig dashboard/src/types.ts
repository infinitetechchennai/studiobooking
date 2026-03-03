export type UserRole = 'vendor' | 'admin';

export interface Equipment {
  id: string;
  name: string;
  category: string;
  status: 'Available' | 'Rented';
  icon: string;
}

export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  status: 'In Stock' | 'Low Stock' | 'Out of Stock';
  icon: string;
}

export interface Booking {
  id: string;
  title: string;
  date: string;
  time: string;
  clientId: string;
  amount: number;
  advance: number;
  type: 'corporate' | 'individual';
}

export interface Staff {
  id: string;
  name: string;
  role: string;
  initials: string;
}

export interface ServiceRate {
  id: string;
  name: string;
  description: string;
  price: number;
  unit: string;
  icon: string;
}

export interface Transaction {
  id: string;
  amount: number;
  status: 'Success' | 'Pending' | 'Failed';
  clientEmail: string;
  type: 'Subscription' | 'One-time';
  timestamp: string;
}

export interface Report {
  id: string;
  from: string;
  role: 'Vendor' | 'User';
  issue: string;
  status: 'Pending' | 'In Review' | 'Resolved';
  timestamp: string;
  image?: string;
}

export interface Creator {
  id: string;
  name: string;
  email: string;
  uid: string;
  status: 'Active' | 'Suspended';
  joinedDate: string;
  avatar: string;
}

export interface UserProfile {
  uid: string;
  email: string;
  name: string;
  role: UserRole;
  shopName?: string;
  bio?: string;
  suspendedUntil: number | null;
  createdAt: number;
  updatedAt?: number;
}
