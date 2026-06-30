/* GANGBOX service worker.
   - App shell loads offline.
   - Same-origin files use stale-while-revalidate so edits (e.g. config.js)
     show up on the next launch instead of being stuck in cache forever.
   - Cross-origin (CDN libs, fonts, Supabase) is network-first with an
     offline cache fallback, so live data stays fresh when online. */
const CACHE = "gangbox-v6";
const SHELL = [
  "./", "./index.html", "./config.js", "./manifest.webmanifest",
  "./icon-192.png", "./icon-512.png", "./icon-512-maskable.png",
  "./apple-touch-icon.png", "./favicon.png",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return; // never touch writes (POST/PATCH/etc.)
  const url = new URL(req.url);

  if (url.origin === self.location.origin) {
    e.respondWith(
      caches.open(CACHE).then(async (cache) => {
        const cached = await cache.match(req);
        const network = fetch(req).then((res) => { cache.put(req, res.clone()); return res; }).catch(() => cached || caches.match("./index.html"));
        return cached || network;
      })
    );
    return;
  }

  e.respondWith(
    fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(req, copy));
      return res;
    }).catch(() => caches.match(req))
  );
});
