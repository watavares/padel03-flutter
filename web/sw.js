// PadelArena Service Worker for PWA functionality

const CACHE_NAME = 'padel-arena-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/favicon.png'
];

// Install event - cache resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('PadelArena: Caching app shell');
        return cache.addAll(urlsToCache);
      })
      .then(() => {
        console.log('PadelArena: Service Worker installed');
        return self.skipWaiting();
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('PadelArena: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('PadelArena: Service Worker activated');
      return self.clients.claim();
    })
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});

// Handle app install prompt
self.addEventListener('beforeinstallprompt', (event) => {
  console.log('PadelArena: Install prompt triggered');
  event.preventDefault();
  // Store the event so it can be triggered later
  self.deferredPrompt = event;
});

// Handle successful app install
self.addEventListener('appinstalled', (event) => {
  console.log('PadelArena: App installed successfully');
});