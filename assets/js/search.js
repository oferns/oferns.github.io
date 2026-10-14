---
layout: null
sitemap: false
---
// Tiny client-side search over /search.json. No index build, no library.
// Front matter above is required: this file contains one Liquid tag.
(function () {
  var form = document.getElementById("search-form");
  var input = document.getElementById("search-q");
  var out = document.getElementById("results");
  if (!form || !input || !out) return;

  var index = null;

  function esc(s) {
    return String(s).replace(/[&<>"]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
    });
  }

  function score(post, terms) {
    var hay = {
      title: (post.title || "").toLowerCase(),
      tags: (post.tags || []).join(" ").toLowerCase(),
      cats: (post.categories || []).join(" ").toLowerCase(),
      excerpt: (post.excerpt || "").toLowerCase(),
      body: (post.body || "").toLowerCase()
    };
    var total = 0;
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i], hits = 0;
      if (hay.title.indexOf(t) > -1) hits += 6;
      if (hay.tags.indexOf(t) > -1) hits += 4;
      if (hay.cats.indexOf(t) > -1) hits += 3;
      if (hay.excerpt.indexOf(t) > -1) hits += 2;
      if (hay.body.indexOf(t) > -1) hits += 1;
      if (hits === 0) return 0; // every term must match somewhere
      total += hits;
    }
    return total;
  }

  function render(q) {
    var terms = q.toLowerCase().split(/\s+/).filter(Boolean);
    if (!terms.length) { out.innerHTML = ""; return; }
    var hits = index
      .map(function (p) { return { p: p, s: score(p, terms) }; })
      .filter(function (r) { return r.s > 0; })
      .sort(function (a, b) { return b.s - a.s; });

    if (!hits.length) {
      out.innerHTML = '<li><p class="meta">No posts match “' + esc(q) + '”.</p></li>';
      return;
    }
    out.innerHTML = hits.map(function (r) {
      var p = r.p;
      return '<li><h2><a href="' + esc(p.url) + '">' + esc(p.title) + "</a></h2>" +
        '<p class="meta">' + esc(p.date) +
        (p.categories && p.categories.length ? " · " + esc(p.categories.join(", ")) : "") +
        "</p>" +
        (p.excerpt ? '<p class="lead">' + esc(p.excerpt) + "</p>" : "") + "</li>";
    }).join("");
  }

  function load() {
    if (index) return Promise.resolve();
    return fetch("{{ '/search.json' | relative_url }}")
      .then(function (r) { return r.json(); })
      .then(function (data) { index = data; });
  }

  function run() {
    var q = input.value.trim();
    var url = new URL(window.location.href);
    if (q) { url.searchParams.set("q", q); } else { url.searchParams.delete("q"); }
    history.replaceState(null, "", url);
    load().then(function () { render(q); });
  }

  form.addEventListener("submit", function (e) { e.preventDefault(); run(); });
  input.addEventListener("input", function () { clearTimeout(input._t); input._t = setTimeout(run, 180); });

  input.value = new URLSearchParams(window.location.search).get("q") || "";
  if (input.value) { load().then(function () { render(input.value.trim()); }); }
})();
