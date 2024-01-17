importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "{{apiKey}}",
  appId: "{{appId}}",
  messagingSenderId: "{{messagingSenderId}}",
  projectId: "{{projectId}}",
  authDomain: "{{authDomain}}",
  storageBucket: "{{storageBucket}}",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage(m => {
  console.log("onBackgroundMessage", m);
});
