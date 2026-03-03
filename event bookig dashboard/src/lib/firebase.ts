import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyBq2JiIV_aDRsarU_g_9_--a69SyulduEw",
    authDomain: "event-booking-app-a9ebe.firebaseapp.com",
    projectId: "event-booking-app-a9ebe",
    storageBucket: "event-booking-app-a9ebe.firebasestorage.app",
    messagingSenderId: "829237859997",
    appId: "1:829237859997:web:5bef4842e468ccefdea674",
    measurementId: "G-2L6F12GPEV"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

export { auth, db };
