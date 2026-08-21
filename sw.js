// Cache-first for the app shell, with runtime caching so cut lists fetched
// once stay available offline. Bump CACHE on every meaningful change so
// old installs evict themselves.

const CACHE = 'cutguide-v9';
const ASSETS = [
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
});
