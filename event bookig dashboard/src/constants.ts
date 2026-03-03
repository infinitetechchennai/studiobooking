import { Equipment, Product, Booking, Staff, ServiceRate, Transaction, Report, Creator } from './types';

export const MOCK_EQUIPMENT: Equipment[] = [
  { id: '1', name: 'RAM 64GB DDR5 (Crucial)', category: 'Computing', status: 'Available', icon: 'memory' },
  { id: '2', name: 'Sony Alpha a7 IV Mirrorless', category: 'Cameras', status: 'Rented', icon: 'videocam' },
  { id: '3', name: 'Aputure LS 600d Pro LED', category: 'Lighting', status: 'Available', icon: 'light' },
];

export const MOCK_PRODUCTS: Product[] = [
  { id: '1', name: 'Casual Blue Denim', description: 'Premium Cotton Fabric', price: 1299, status: 'In Stock', icon: 'apparel' },
  { id: '2', name: 'Leather Sneakers', description: 'Handcrafted Brown Leather', price: 2450, status: 'In Stock', icon: 'footprint' },
  { id: '3', name: 'dam', description: 'Utility Accessory', price: 24, status: 'Low Stock', icon: 'inventory_2' },
];

export const MOCK_BOOKINGS: Booking[] = [
  { id: '1', title: 'Corporate Booking', date: 'Feb 18', time: '10:00 AM', clientId: 'zgHdB...', amount: 26.40, advance: 3.96, type: 'corporate' },
  { id: '2', title: 'Corporate Event', date: 'Feb 19', time: '02:30 PM', clientId: 'kL9xR...', amount: 45.00, advance: 10.00, type: 'corporate' },
  { id: '3', title: 'Quarterly Sync', date: 'Feb 20', time: '09:00 AM', clientId: 'mN2vP...', amount: 12.80, advance: 2.00, type: 'corporate' },
];

export const MOCK_STAFF: Staff[] = [
  { id: '1', name: 'Alice Johnson', role: 'Studio Manager', initials: 'AJ' },
  { id: '2', name: 'Bob Smith', role: 'Lead Technician', initials: 'BS' },
  { id: '3', name: 'Carla Velez', role: 'Inventory Specialist', initials: 'CV' },
  { id: '4', name: 'David Thompson', role: 'Security Head', initials: 'DT' },
];

export const MOCK_RATES: ServiceRate[] = [
  { id: '1', name: 'Studio Rental', description: 'Hourly access to main studio space', price: 25, unit: 'per hour', icon: 'camera_indoor' },
  { id: '2', name: 'Equipment Pack', description: 'Lighting and tripod essential kit', price: 15, unit: 'per session', icon: 'lightbulb' },
  { id: '3', name: 'Assistant Fee', description: 'Junior production assistant', price: 10, unit: 'per hour', icon: 'person_pin_circle' },
];

export const MOCK_TRANSACTIONS: Transaction[] = [
  { id: '1', amount: 120.00, status: 'Success', clientEmail: 'alex.smith@example.com', type: 'Subscription', timestamp: 'Oct 24, 2023, 14:20' },
  { id: '2', amount: 85.50, status: 'Pending', clientEmail: 'm.johnson@provider.net', type: 'One-time', timestamp: 'Oct 24, 2023, 15:45' },
  { id: '3', amount: 240.00, status: 'Success', clientEmail: 'k.williams@company.org', type: 'Subscription', timestamp: 'Oct 23, 2023, 09:12' },
  { id: '4', amount: 45.00, status: 'Failed', clientEmail: 'd.brown@mail.com', type: 'One-time', timestamp: 'Oct 23, 2023, 11:30' },
  { id: '5', amount: 1200.00, status: 'Success', clientEmail: 'l.davis@service.io', type: 'Subscription', timestamp: 'Oct 22, 2023, 16:20' },
  { id: '6', amount: 32.00, status: 'Success', clientEmail: 's.miller@web.com', type: 'One-time', timestamp: 'Oct 22, 2023, 10:05' },
];

export const MOCK_REPORTS: Report[] = [
  { id: '1', from: 'vendor.support@shop.com', role: 'Vendor', issue: 'The payment gateway failed during the checkout process for the last three customers. They received a 504 Gateway Timeout error, but funds were held in their bank accounts.', status: 'Pending', timestamp: 'Oct 24, 2023 • 10:45 AM', image: 'https://picsum.photos/seed/report1/400/300' },
  { id: '2', from: 'user.one@gmail.com', role: 'User', issue: "Unable to change my account password. Every time I click the confirmation link in the email, the page says 'Invalid Link'. I've tried multiple times over the last 2 hours.", status: 'In Review', timestamp: 'Oct 24, 2023 • 09:12 AM', image: 'https://picsum.photos/seed/report2/400/300' },
  { id: '3', from: 'logistics@fastmove.net', role: 'Vendor', issue: 'Tracking API sync is lagging. Customers are seeing "Package Not Dispatched" even after we\'ve updated the status in our warehouse management system.', status: 'Pending', timestamp: 'Oct 23, 2023 • 04:30 PM', image: 'https://picsum.photos/seed/report3/400/300' },
  { id: '4', from: 'mark.taylor@outlook.com', role: 'User', issue: "Refund was not credited back to my account after order cancellation. I cancelled order #12345 three days ago but haven't seen the funds.", status: 'Resolved', timestamp: 'Oct 23, 2023 • 11:20 AM', image: 'https://picsum.photos/seed/report4/400/300' },
];

export const MOCK_CREATORS: Creator[] = [
  { id: '1', name: 'Alex Rivera', email: 'alex.r@email.com', uid: 'CR-88291', status: 'Active', joinedDate: 'Oct 12, 2023', avatar: 'https://lh3.googleusercontent.com/a/default-user' },
  { id: '2', name: 'Sarah Chen', email: 's.chen@provider.net', uid: 'CR-77402', status: 'Active', joinedDate: 'Sep 28, 2023', avatar: 'https://lh3.googleusercontent.com/a/default-user' },
  { id: '3', name: 'Marcus Thorne', email: 'm.thorne@studio.com', uid: 'CR-99103', status: 'Suspended', joinedDate: 'Aug 05, 2023', avatar: 'https://lh3.googleusercontent.com/a/default-user' },
  { id: '4', name: 'Elena Rodriguez', email: 'elena.rod@mail.com', uid: 'CR-11024', status: 'Active', joinedDate: 'Nov 02, 2023', avatar: 'https://lh3.googleusercontent.com/a/default-user' },
  { id: '5', name: 'Jordan Smith', email: 'jsmith@web.com', uid: 'CR-55621', status: 'Active', joinedDate: 'Dec 20, 2023', avatar: 'https://lh3.googleusercontent.com/a/default-user' },
];
