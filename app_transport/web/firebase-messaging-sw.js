importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
  authDomain: 'transit-app-307ac.firebaseapp.com',
  databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  projectId: 'transit-app-307ac',
  storageBucket: 'transit-app-307ac.firebasestorage.app',
  messagingSenderId: '83204859004',
  appId: '1:83204859004:web:xxxxxxxxxxxxxxxx'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  const title = payload.notification?.title || 'New Notification';
  const options = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(title, options);
});
