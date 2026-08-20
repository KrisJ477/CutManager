<<<<<<< HEAD
// Minimal cache-first service worker.
// Its main job is to satisfy Chrome's installability requirement (a fetch
// handler must exist), with offline use as a genuine bonus on a shop floor
// with patchy wifi.

const CACHE = 'cutguide-v1';
=======
// Cache-first for the app shell, with runtime caching so cut lists fetched
// once stay available offline.

const CACHE = 'cutguide-v2';
>>>>>>> 153eb81 (Deploy 2026-08-20 16:46:32,58)
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon.svg',
<<<<<<< HEAD
  './icon-maskable.svg'
=======
  './icon-maskable.svg',
  './lists/index.json'
>>>>>>> 153eb81 (Deploy 2026-08-20 16:46:32,58)
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(ASSETS))
      .then(() => self.skipWaiting())
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
<<<<<<< HEAD
  if (event.request.method !== 'GET') return;
  event.respondWith(
    caches.match(event.request).then(hit => hit || fetch(event.request))
  );
=======
  const req = event.request;
  if (req.method !== 'GET') return;

  // Cut lists: network first so edits pushed to git show up, falling back to
  // cache when the shop wifi is not cooperating.
  if (req.url.includes('/lists/')) {
    event.respondWith(
      fetch(req)
        .then(res => {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
          return res;
        })
        .catch(() => caches.match(req))
    );
    return;
  }

  event.respondWith(caches.match(req).then(hit => hit || fetch(req)));
>>>>>>> 153eb81 (Deploy 2026-08-20 16:46:32,58)
});
