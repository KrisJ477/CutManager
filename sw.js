// Network-first for everything, cache only as an offline fallback.
//
// The old cache-first strategy meant a deployed update was invisible
// until the cache was manually cleared - the whole point of a service
// worker fighting against you. Now the newest files always win when
// there is a connection, and the cache is purely a fallback for when
// the shop wifi drops. Cut records live in localStorage and are never
// touched by any of this.

const CACHE = 'cutguide-runtime';
const SHELL = [
  './',
  './index.html',
  './cutdata.js',
  './manifest.webmanifest',
  './icon.svg',
  './icon-maskable.svg'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(SHELL))
      .then(() => self.skipWaiting())     // take over immediately
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;
  if (new URL(req.url).origin !== self.location.origin) return;

  event.respondWith(
    // cache: 'no-store' bypasses the browser HTTP cache too. GitHub Pages
    // sends a ten minute max-age, which would otherwise still serve a
    // stale index.html even though we are asking the network.
    fetch(new Request(req, { cache: 'no-store' }))
      .then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        return res;
      })
      .catch(() => caches.match(req).then(hit => hit || caches.match('./index.html')))
  );
});
