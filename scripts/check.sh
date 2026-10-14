#!/usr/bin/env bash
# Smoke assertions over a built site. Run by `rake check` locally and by CI,
# so there is one source of truth. Usage: scripts/check.sh [_site]
set -euo pipefail

site="${1:-_site}"

if [[ ! -d "$site" ]]; then
  echo "error: '$site' is not a directory — run 'rake build' first" >&2
  exit 1
fi

fail() { echo "FAIL: $1" >&2; exit 1; }

# --- pages that must exist -------------------------------------------------
for f in index.html sitemap.xml feed.xml 404.html \
         search/index.html categories/index.html tags/index.html \
         assets/css/main.css assets/css/dark.css assets/css/custom.css; do
  [[ -f "$site/$f" ]] || fail "missing $site/$f"
done

# --- a post page must be rendered (permalink is /:categories/:y/:m/:d/:title)
post_page="$(find "$site" -name '*.html' -not -path '*/assets/*' -not -name 'index.html' -not -name '404.html' | sort | head -1)"
[[ -n "$post_page" ]] || fail "no post page found under $site"

# --- absolute URLs in the sitemap (needs site.url in _config.yml) ----------
grep -q '<loc>https://oferns.github.io/' "$site/sitemap.xml" \
  || fail "sitemap <loc> values are not absolute — is site.url set?"

# --- theme actually rendered, not a fallback theme -------------------------
grep -q 'class="masthead"' "$site/index.html" || fail "no masthead: theme did not render"
grep -q 'id="skin-toggle"' "$site/index.html" || fail "no skin toggle: _includes/footer/custom.html not used"
grep -q 'href="/assets/css/custom.css"' "$site/index.html" \
  || fail "custom.css link missing or malformed"

# --- nav from _data/navigation.yml ----------------------------------------
grep -q 'href="/search/"' "$site/index.html" || fail "search link missing from masthead"

# --- features enabled in _config.yml --------------------------------------
grep -Eq 'min(ute)?s? read' "$post_page" || fail "reading time not rendered in $post_page"
grep -q 'page__related' "$post_page" || fail "related posts section not rendered in $post_page"
grep -q 'href="/tags/#' "$post_page" || fail "tag archive links missing in $post_page"
[[ -f "$site/assets/js/lunr/lunr-store.js" ]] || fail "lunr search index missing (search: true?)"

# --- MathJax must be pinned + SRI'd on posts that opt in ------------------
if grep -q 'mathjax' "$post_page"; then
  grep -E -q 'mathjax@[0-9]+\.[0-9]+\.[0-9]+' "$post_page" \
    || fail "MathJax CDN URL is not pinned to an exact version"
  grep -q 'integrity="sha384-' "$post_page" || fail "MathJax script has no SRI integrity hash"
fi

# --- repo docs must NOT be published (Jekyll would render their Liquid) ---
[[ ! -e "$site/AGENTS.md" ]] || fail "AGENTS.md is being published"
[[ ! -e "$site/README.md" ]] || fail "README.md is being published"

echo "OK: all checks passed against $site"
