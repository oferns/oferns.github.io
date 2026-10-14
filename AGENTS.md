# AGENTS.md

Personal blog for Oliver Ferns. Jekyll site published to GitHub Pages (user page repo, `master`,
served at `https://oferns.github.io` at the root path — `baseurl` is empty).

## Stack

| | |
|---|---|
| Ruby | `3.4.3` (`.ruby-version`; CI uses it via `ruby/setup-ruby`) |
| Jekyll | `4.4.1` |
| Theme | `minimal-mistakes-jekyll` `4.28.1`, **gem-based** via `theme:` in `_config.yml` |
| Markdown / highlighter | kramdown (GFM) / Rouge |
| Deps | `Gemfile` + committed `Gemfile.lock`; Dependabot opens weekly bundler + github-actions PRs |

There is **no** `remote_theme` and **no** `_config.local.yml` any more — local, CI and production all
build from the same `Gemfile` and `_config.yml`. `rouge` is capped at `< 5.0` by Jekyll 4.4.1; don't
try to force Rouge 5.

## Commands

```sh
bundle install
rake serve    # dev server + live reload, http://localhost:4000
rake build    # build to _site
rake check    # build + scripts/check.sh — this is the verification step
rake new TITLE="My post" TAGS=a,b CATEGORY=math
rake update   # bundle update, then rake check
```

`_site/` and `.jekyll-cache/` are build artifacts — gitignored, never edit them.

**`scripts/check.sh` is the single source of truth for smoke assertions** (pages exist, sitemap
`<loc>` is absolute, theme chrome rendered, reading time + related posts present, lunr index built,
MathJax pinned + SRI'd, repo docs not published). CI runs exactly `bash scripts/check.sh _site`.
Add new assertions **there**, not in the workflow file.

## Deployment

`.github/workflows/deploy.yml`: `ruby/setup-ruby` (bundler cache) → `bundle exec jekyll build`
(`JEKYLL_ENV=production`) → `scripts/check.sh` → `actions/upload-pages-artifact@v5` →
`actions/deploy-pages@v5` (master pushes only; PRs build and assert, never deploy).

- Pages' build source **must** be set to "GitHub Actions". If it is ever set back to "Deploy from a
  branch", production reverts to the frozen `github-pages` gem (Jekyll 3.10), the repo's Gemfile is
  ignored, and the local/production skew that broke the 2026 reboot comes back.
- The `deploy` job needs `permissions: pages: write, id-token: write` and the `github-pages`
  environment. Don't trim those.
- After pushing: `gh run list`, then `gh run view <id> --log` on failure. A failed workflow leaves the
  previous deployment live.

## Adding a post

`rake new TITLE="…"` scaffolds `_posts/YYYY-MM-DD-slug.md`. Front matter defaults in `_config.yml`
supply `layout: single`, `author_profile`, `read_time`, `related`, `comments: false`, `share: false`
— don't repeat them in posts.

- **MathJax is per-page** (`mathjax: true`). Minimal Mistakes 4.28.1 has **no built-in MathJax**
  (grep the gem: zero hits), so `_includes/head/custom.html` is the only loader. It is pinned to an
  exact version with an SRI hash; when bumping, recompute the hash:
  `curl -s https://cdn.jsdelivr.net/npm/mathjax@<ver>/es5/tex-mml-chtml.js | openssl dgst -sha384 -binary | openssl base64 -A`
  `scripts/check.sh` fails if the URL is unpinned (e.g. `mathjax@3`) or the hash is missing.
- Post permalink is MM's default `/:categories/:year/:month/:day/:title.html` — nested dirs on disk.
- `<!--more-->` sets where the home-page preview cuts; `excerpt:` in front matter wins.
- `header.teaser: /assets/images/x.png` gives a thumbnail in post lists.

## Customization points

Theme hooks and data overrides only — never vendor theme files into the repo:

- `_includes/head/custom.html` — MathJax loader, dark-stylesheet preload, pre-paint skin script.
- `_includes/footer/custom.html` — light/dark toggle + `localStorage` key `mm-skin`.
- `assets/css/dark.scss` — a **second full compile** of the theme with the dark skin variables,
  toggled at runtime by enabling/disabling the `#skin-dark` link. ~107 KB (~19 KB gz); browsers fetch
  `disabled` stylesheets, so every visitor downloads it. Accepted cost of a no-FOUC toggle, cached
  site-wide — don't "optimize" it away. Styles that must work in both skins go in
  `assets/css/custom.css`.
- `_data/navigation.yml` — masthead links; overrides the theme gem's placeholder navigation.
- Pages at the root: `search.md` (`layout: search`), `categories.md` (`layout: categories`),
  `tags.md` (`layout: tags`), `404.md` (`permalink: /404.html`).

Features enabled in `_config.yml`: `search` (lunr, `search_full_content: false`), `reading_time`,
`related`, `enable_copy_code_button`, `category_archive`/`tag_archive` with `type: liquid`
(anchor links on the archive pages — no per-category/tag pages are generated).

Plugins: `jekyll-paginate`, `jekyll-sitemap`, `jekyll-seo-tag`, `jekyll-feed`,
`jekyll-include-cache`. All are in the Gemfile's `:jekyll_plugins` group **and** listed under
`plugins:`.

## Gotchas

- **`jekyll-include-cache` must stay in `plugins:`.** MM's `_layouts/default.html` uses
  `{% include_cached %}`. Omitting it fails the build with `Unknown tag 'include_cached'`.
- **Published markdown is rendered through Liquid.** `AGENTS.md`, `README.md`, `Rakefile`, `scripts/`,
  `.github/`, `.ruby-version` and `Gemfile*` are in `exclude:` for that reason — a literal
  `{% include_cached %}` in prose once failed the build with `Could not locate the included file ''`.
  If you add a new root-level file, add it to `exclude:`. Liquid examples inside published posts need
  `{% raw %}`.
- **`url: "https://oferns.github.io"` is not cosmetic.** With it empty, `jekyll-sitemap` emits
  relative `<loc>` (invalid) and `jekyll-seo-tag`/`jekyll-feed` emit relative canonical, `og:url`,
  `<id>`. Asset paths use `baseurl`, so setting `url` is safe.
- A clean build prints **no** Sass warnings. The theme's vendored Susy emits ~230
  `slash-div`/`@import` deprecations, silenced by `sass: quiet_deps` + `silence_deprecations`. Valid
  ids only — `function` and `mixin-deprecation` are rejected, `mixed-decls` is obsolete and warns.
  If warnings reappear after a theme bump, adjust that list; don't edit theme SCSS.
- Font Awesome is loaded from `@fortawesome/fontawesome-free@latest` — hardcoded in the theme's
  `_includes/head.html` with no config knob. Pinning it means vendoring that include; the light/dark
  toggle icons depend on it.
- `author.avatar` is **commented out** in `_config.yml`; uncomment it only once
  `assets/images/bio-photo.jpg` exists.
- `author.links` drives the footer icons; `site.twitter` / `twitter_image` / `og_image` are
  commented out until real handles/images exist.
- No custom domain: Pages reports `cname: null`. Don't add a `CNAME` file.
- No test framework and no linters. Verification = `rake check` (same as CI) plus eyeballing the
  rendered page in both light and dark skins.
