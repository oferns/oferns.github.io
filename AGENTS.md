# AGENTS.md

Personal blog for Oliver Ferns. Plain Jekyll published to GitHub Pages (user page repo, `master`,
`https://oferns.github.io` at the root path, `baseurl` empty). **No theme gem and no front-end
libraries** — the layouts, CSS and JS in this repo are the whole front end.

## Stack

| | |
|---|---|
| Ruby | `3.4.3` (`.ruby-version`; CI reads it via `ruby/setup-ruby`) |
| Jekyll | `4.4.1` |
| Gems (38 total) | `jekyll`, `jekyll-seo-tag`, `jekyll-feed`, `jekyll-sitemap`, `rake`, `webrick` |
| Front end | `assets/css/main.css`, `assets/css/highlight.css` (generated), `assets/js/theme.js`, `assets/js/search.js` |
| Markdown / highlighter | kramdown (GFM) / Rouge (built into Jekyll) |
| Deps | committed `Gemfile.lock`; Dependabot weekly for bundler + github-actions |

`bundle list` should stay near 38 gems. `sass-embedded` + `google-protobuf` are installed because
Jekyll hard-depends on `jekyll-sass-converter`, but nothing here is SCSS — they go unused.

## Commands

```sh
bundle install
rake serve      # dev server + live reload, http://localhost:4000
rake build      # build to _site
rake check      # build + scripts/check.sh — the verification step
rake new TITLE="My post" TAGS=a,b CATEGORY=math
rake highlight  # regenerate assets/css/highlight.css from Rouge
rake update     # bundle update, then rake check
```

`_site/` and `.jekyll-cache/` are artifacts — gitignored, never edit them.

**`scripts/check.sh` is the single source of truth for smoke assertions** and CI runs exactly
`bash scripts/check.sh _site`. It asserts: required pages exist; the post permalink shape; absolute
sitemap `<loc>` and canonical; posts listed on the home page; reading time + tags rendered; dark-mode
`data-theme` hook and CSS custom properties present; inline SVG present; search link + non-empty
`search.json`; MathJax pinned + SRI where used; **Font Awesome / jQuery / lunr / `dark.css` absent**;
repo docs not published; and a **home-page CSS+JS payload budget of 8 KB gzipped** (currently ~4 KB).
Add new assertions there, not in the workflow file. If you intentionally change any of this, update
`scripts/check.sh` in the same commit.

## Deployment

`.github/workflows/deploy.yml`: `ruby/setup-ruby` (bundler cache) → `bundle exec jekyll build`
(`JEKYLL_ENV=production`) → `scripts/check.sh` → `actions/upload-pages-artifact@v5` →
`actions/deploy-pages@v5` (master pushes only; PRs build + assert, never deploy).

- Pages' build source must be **"GitHub Actions"**. If it is set to "Deploy from a branch",
  production reverts to the frozen `github-pages` gem (Jekyll 3.10) and this Gemfile is ignored.
- The `deploy` job needs `permissions: pages: write, id-token: write` and the `github-pages`
  environment — don't trim them.
- After pushing: `gh run list`, then `gh run view <id> --log`. A failed workflow leaves the previous
  deployment live.

## Adding a post

`rake new TITLE="…"` scaffolds `_posts/YYYY-MM-DD-slug.md`. `layout: post` comes from `defaults:` in
`_config.yml`; don't repeat it in posts.

- **Permalinks are pinned**: `permalink: /:categories/:year-:month-:day/:title:output_ext` produces
  `/meta/2026-09-17/hello-world.html`. Jekyll's bare default (`/2026/09/17/hello-world.html`) would
  change every URL. `scripts/check.sh` fails if the shape changes.
- **MathJax is per-page** (`mathjax: true`). `_includes/mathjax.html` is pinned to an exact version
  with an SRI hash; when bumping, recompute:
  `curl -s https://cdn.jsdelivr.net/npm/mathjax@<ver>/es5/tex-mml-chtml.js | openssl dgst -sha384 -binary | openssl base64 -A`
- `excerpt:` in front matter wins over the `<!--more-->` split for the home page list.
- Categories/tags feed `/categories/` and `/tags/` automatically — no pages to create per taxonomy.

## Customization points

- **`assets/css/main.css`** — every colour/size decision lives in the `:root` token block, with
  `[data-theme="dark"]` and `@media (prefers-color-scheme: dark)` overrides. Add a token, don't
  hard-code a colour.
- **`assets/css/highlight.css` is generated** — edit `scripts/gen-highlight.rb` (Rouge theme names)
  and run `rake highlight`. Never hand-edit it.
- **`_layouts/default.html`** — head, nav, footer. Nav links are inline here (there is no data file).
- **`_includes/icon.html`** — add icons as `{%- when "name" -%}<svg …>` and use
  `{% include icon.html name="name" %}`. Icons are inline SVG on purpose: no icon font.
- **`_layouts/home.html` / `post.html`** — list and article markup (reading time, tags, prev/next,
  related-by-shared-tag).
- **`assets/js/theme.js`** — theme toggle (writes `data-theme` + `localStorage` key `skin`) and
  copy-code buttons. The pre-paint script lives in `_layouts/default.html` to avoid a flash.
- **`search.md` + `search.json` + `assets/js/search.js`** — client-side search. `search.json` embeds
  full post bodies; if the blog grows past a few hundred posts, truncate it there.

## Gotchas

- **Jekyll 4 has no built-in pagination.** `paginate:` in `_config.yml` without the
  `jekyll-paginate` gem emits a deprecation warning and renders an **empty** home page. The bare
  design lists posts directly with `home_post_limit`; if you ever add real pagination, add the gem
  and update `scripts/check.sh`.
- **Published markdown is rendered through Liquid.** `AGENTS.md`, `README.md`, `Rakefile`, `scripts/`,
  `.github/`, `.ruby-version`, `Gemfile*` are in `exclude:` — a literal `{% … %}` in prose once failed
  the build with `Could not locate the included file ''`. New root-level files go in `exclude:`.
  Liquid examples inside published posts need `{% raw %}`.
- **`assets/js/search.js` has front matter on purpose** (`layout: null`) so its one Liquid tag is
  processed. Removing the front matter ships the raw Liquid to the browser.
- **`url: "https://oferns.github.io"` is not cosmetic** — with it empty, `jekyll-sitemap` emits
  relative `<loc>` (invalid) and `jekyll-seo-tag`/`jekyll-feed` emit relative canonical, `og:url`,
  `<id>`. Asset paths use `baseurl`, so setting `url` is safe.
- **Don't reintroduce dependencies.** CI fails the build if Font Awesome, jQuery, lunr or a
  `dark.css` stylesheet appear. Dark mode is a variable swap; icons are inline SVG; search is
  `search.json` + vanilla JS.
- **`rouge` is capped at `< 5.0`** by Jekyll 4.4.1 — don't force Rouge 5.
- `author.avatar` / `og_image` / `twitter` are not wired up; `assets/favicon.svg` is a hand-written
  monogram.
- No custom domain: Pages reports `cname: null`. Don't add a `CNAME` file.
- No test framework, no linter. Verification = `rake check` (same as CI) plus eyeballing the site in
  both light and dark skins.
