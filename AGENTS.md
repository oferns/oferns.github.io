# AGENTS.md

Personal blog for Oliver Ferns. Plain Jekyll 4.4 on GitHub Pages (user page repo, `master`,
`https://oferns.github.io` at the root, `baseurl` empty). **No theme gem, no CSS framework, no icon
font, no JS libraries** — the layouts, CSS and JS in this repo are the entire front end.

## Stack & commands

Ruby `3.4.3` (`.ruby-version`, also used by CI). Gems: `jekyll`, `jekyll-seo-tag`, `jekyll-feed`,
`jekyll-sitemap`, `rake`, `webrick` — 38 installed, keep it near that. (`sass-embedded` and
`google-protobuf` arrive via Jekyll and go unused: nothing here is SCSS.)

```sh
bundle install
rake serve      # dev server + live reload on :4000
rake check      # build + scripts/check.sh — the verification step
rake new TITLE="My post" TAGS=a,b CATEGORY=math
rake highlight  # regenerate assets/css/highlight.css from Rouge
rake update     # bundle update, then rake check
```

`_site/` and `.jekyll-cache/` are artifacts: gitignored, never edit.

## Verification

`scripts/check.sh` is the source of truth; CI runs exactly `bash scripts/check.sh _site`. It asserts:
required pages exist · post permalink shape · absolute sitemap `<loc>` and canonical · home page lists
posts · reading time and tags render · dark-mode `data-theme` hook and CSS tokens present · inline SVG
present · search wired and `search.json` non-empty · MathJax pinned + SRI where used · **Font Awesome,
jQuery, lunr and `dark.css` absent** · repo docs not published · home-page CSS+JS ≤ 8 KB gzipped
(currently ~4 KB).

Add new assertions **there**, never in the workflow file, and update it in the same commit as any
intentional change it rejects.

## Deployment

`.github/workflows/deploy.yml`: `ruby/setup-ruby` (bundler cache) → `bundle exec jekyll build`
(`JEKYLL_ENV=production`) → `scripts/check.sh` → `upload-pages-artifact` → `deploy-pages` (master
pushes only; PRs build and assert, no deploy). Needs `pages: write` + `id-token: write` and the
`github-pages` environment — don't trim them.

- Pages' build source must be **"GitHub Actions"**. "Deploy from a branch" reverts production to the
  frozen `github-pages` gem (Jekyll 3.10) and ignores this Gemfile.
- After pushing: `gh run list`, then `gh run view <id> --log`. A failed workflow leaves the previous
  deployment live.

## Posts

`rake new TITLE="…"` scaffolds `_posts/YYYY-MM-DD-slug.md`. `layout: post` comes from `defaults:` in
`_config.yml` — don't repeat it. `excerpt:` in front matter beats `<!--more-->` for the home list.
Categories/tags feed `/categories/` and `/tags/` automatically; no per-taxonomy pages exist.

MathJax is **per-page** (`mathjax: true`) and pinned with an SRI hash in `_includes/mathjax.html`;
when bumping the version, recompute the hash:
`curl -s https://cdn.jsdelivr.net/npm/mathjax@<ver>/es5/tex-mml-chtml.js | openssl dgst -sha384 -binary | openssl base64 -A`

## Where things go

| Change | File |
|---|---|
| Colour, spacing, typography | `assets/css/main.css` — edit the `:root` token block (and its dark overrides); never hard-code a colour |
| Code-highlighting colours | `scripts/gen-highlight.rb`, then `rake highlight` — `assets/css/highlight.css` is generated, don't hand-edit |
| Nav, `<head>`, footer | `_layouts/default.html` (nav links are inline; there is no data file) |
| New icon | add a `{%- when "name" -%}` case to `_includes/icon.html`, use `{% include icon.html name="name" %}` |
| List / article markup | `_layouts/home.html`, `_layouts/post.html` |
| Theme toggle, copy buttons | `assets/js/theme.js` (the pre-paint script is in `_layouts/default.html`) |
| Search | `search.md` + `search.json` + `assets/js/search.js` |

## Gotchas

- **Jekyll 4 has no built-in pagination.** `paginate:` in `_config.yml` without the
  `jekyll-paginate` gem warns and renders an **empty** home page. The home list uses
  `home_post_limit` (0 = show all).
- **Published markdown is rendered through Liquid.** Root-level docs are in `exclude:` for that
  reason — add new root-level files there. Liquid examples inside posts need `{% raw %}`.
- **`assets/js/search.js` must keep its `---` front matter**: it contains one Liquid tag.
- **`url:` in `_config.yml` is load-bearing.** With it empty, `jekyll-sitemap` emits relative `<loc>`
  (invalid) and `jekyll-seo-tag`/`jekyll-feed` emit relative canonical, `og:url` and `<id>`. Asset
  paths use `baseurl`, so setting `url` is safe.
- **Permalinks are pinned** to `/:categories/:year-:month-:day/:title:output_ext` so published URLs
  survive; Jekyll's bare default would change them all.
- **Don't reintroduce dependencies.** CI fails on Font Awesome, jQuery, lunr or a `dark.css`
  stylesheet: dark mode is a CSS variable swap, icons are inline SVG, search is `search.json` + JS.
- **`rouge` is capped at `< 5.0`** by Jekyll 4.4.1 — don't force Rouge 5.
- No custom domain (`cname: null`): don't add a `CNAME` file. No test framework — `rake check` is it.
