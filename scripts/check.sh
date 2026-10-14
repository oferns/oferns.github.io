#!/usr/bin/env bash
# Smoke assertions over a built site. Run by `rake check` locally and by CI,
# so there is one source of truth. Usage: scripts/check.sh [_site]
set -euo pipefail

site="${1:-_site}"
[[ -d "$site" ]] || { echo "error: '$site' is not a directory — run 'rake build' first" >&2; exit 1; }
fail() { echo "FAIL: $1" >&2; exit 1; }

# --- pages that must exist -------------------------------------------------
for f in index.html sitemap.xml feed.xml robots.txt 404.html \
         search/index.html search.json categories/index.html tags/index.html \
         assets/css/main.css assets/css/highlight.css assets/js/theme.js \
         assets/js/search.js assets/favicon.svg; do
  [[ -f "$site/$f" ]] || fail "missing $site/$f"
done

# --- a post page, at the pinned permalink ----------------------------------
post_page="$(find "$site" -name '*.html' -not -path '*/assets/*' -not -name index.html -not -name 404.html | sort | head -1)"
[[ -n "$post_page" ]] || fail "no post page found under $site"
[[ "$post_page" == *"/meta/2026-09-17/hello-world.html" ]] \
  || fail "post permalink changed: expected /:categories/:year-:month-:day/:title.html, got $post_page"

# --- absolute URLs (needs site.url in _config.yml) -------------------------
grep -q '<loc>https://oferns.github.io/' "$site/sitemap.xml" \
  || fail "sitemap <loc> is not absolute — is site.url set?"
grep -q '<link rel="canonical" href="https://oferns.github.io/' "$site/index.html" \
  || fail "canonical URL is not absolute"

# --- features --------------------------------------------------------------
grep -q 'Hello world' "$site/index.html" || fail "home page does not list posts"
grep -q 'data-theme' "$site/index.html" || fail "no data-theme hook: dark mode is broken"
grep -q -- '--bg' "$site/assets/css/main.css" || fail "no CSS custom properties in main.css"
grep -q 'id="skin-toggle"' "$site/index.html" || fail "theme toggle missing"
grep -q '<svg' "$site/index.html" || fail "no inline SVG icons"
grep -Eq 'min(ute)?s? read' "$post_page" || fail "reading time not rendered in $post_page"
grep -q 'class="tags"' "$post_page" || fail "tag list not rendered in $post_page"
grep -q 'href="/search/"' "$site/index.html" || fail "search link missing from nav"
grep -q '"title"' "$site/search.json" || fail "search.json is empty"

# --- MathJax must be pinned + SRI'd where it is used -----------------------
if grep -q 'mathjax' "$post_page"; then
  grep -Eq 'mathjax@[0-9]+\.[0-9]+\.[0-9]+' "$post_page" \
    || fail "MathJax is not pinned to an exact version"
  grep -q 'integrity="sha384-' "$post_page" || fail "MathJax has no SRI integrity hash"
fi

# --- the stripped dependencies must stay gone ------------------------------
if grep -rqi 'fontawesome' "$site"; then fail "Font Awesome crept back in"; fi
if grep -rqi 'jquery' "$site"; then fail "jQuery crept back in"; fi
if grep -rqi 'lunr' "$site"; then fail "lunr crept back in"; fi
if [[ -e "$site/assets/css/dark.css" ]]; then fail "dark.css exists — dark mode should be CSS variables"; fi

# --- repo docs must NOT be published (Jekyll renders published .md as Liquid)
[[ ! -e "$site/AGENTS.md" ]] || fail "AGENTS.md is being published"
[[ ! -e "$site/README.md" ]] || fail "README.md is being published"

# --- payload budget: CSS + JS referenced by the home page, gzipped ---------
bytes=0
for a in $(grep -o 'href="/assets/css/[^"]*"\|src="/assets/js/[^"]*"' "$site/index.html" \
           | grep -o '/assets/[^"]*' | sort -u); do
  if [[ -f "$site$a" ]]; then bytes=$((bytes + $(gzip -c "$site$a" | wc -c | tr -d ' '))); fi
done
echo "payload: home page CSS+JS = ${bytes} bytes gzipped"
[[ "$bytes" -le 8192 ]] || fail "home page CSS+JS is ${bytes} bytes gz (budget 8192)"

echo "OK: all checks passed against $site"
