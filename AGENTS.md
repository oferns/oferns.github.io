# AGENTS.md

Personal blog for Oliver Ferns. Jekyll site on GitHub Pages (user page repo, `master` branch,
served at `https://oferns.github.io` at the root path — `baseurl` is intentionally empty).

## Theme

[Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) `4.28.1`, loaded in two ways:

- **On GitHub Pages**: `remote_theme: mmistakes/minimal-mistakes` in `_config.yml`. No build tooling
  on GitHub's side; the Gemfile is ignored there.
- **Locally**: `_config.local.yml` swaps in the installed `minimal-mistakes-jekyll` gem. It is
  gitignored — keep it that way, and never add `theme:` to `_config.yml` (that breaks Pages).

## Commands

```sh
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml   # http://localhost:4000
bundle exec jekyll build  --config _config.yml,_config.local.yml  # the only verification step
```

Always pass `--config _config.yml,_config.local.yml` locally; a plain `jekyll serve` uses
`remote_theme` and needs network access. `_site/`, `.jekyll-cache/` are build artifacts — gitignored,
never edit them.

A clean build prints **no** Sass warnings. The theme's vendored Susy emits ~230
`slash-div`/`@import` deprecations, silenced by `sass: quiet_deps` + `silence_deprecations` in
`_config.yml`. If warnings reappear, a theme upgrade changed them — do not "fix" the theme's SCSS.
(Valid ids only: `function` and `mixin-deprecation` are rejected, and `mixed-decls` is obsolete and
warns. GitHub Pages runs jekyll-sass-converter 2.x, which ignores these keys entirely.)

## Adding a post

File in `_posts/` named `YYYY-MM-DD-slug.md`:

```markdown
---
title: "My new post"
date: 2026-09-18
categories: some-category
mathjax: true   # optional, per-post opt-in
---
```

- Front matter default in `_config.yml` sets `layout: single` on all posts — don't repeat it.
- MathJax is **per-page only**. Minimal Mistakes 4.28.1 has **no built-in MathJax** (grep the gem:
  zero hits), so `_includes/head/custom.html` is the only loader — the per-page opt-in is
  load-bearing, not cosmetic.
- Markdown is kramdown with GFM input + Rouge highlighting.
- Home page is `index.html` with `layout: home`; pagination is 5 posts/page. Don't add markup to it.

## Customization points

Theme hooks are the only place to override presentation — do not vendor theme files:

- `_includes/head/custom.html` — MathJax loader + dark-stylesheet preload + pre-paint skin script.
- `_includes/footer/custom.html` — light/dark toggle button and its localStorage (`mm-skin`) logic.
- `assets/css/dark.scss` — a **second full compile** of the theme with the dark skin variables;
  toggled at runtime by enabling/disabling the `#skin-dark` link. It is ~107 KB (~19 KB gz) and
  browsers fetch `disabled` stylesheets, so every visitor downloads it. That is the accepted cost of
  the no-FOUC toggle and is cached site-wide — don't "optimize" it away. Anything that must work in
  both skins belongs in `assets/css/custom.css`, not here.
- `_config.yml` — title, `author:` bio block, plugins, pagination, timezone (`Europe/London`).

Allowed plugins are the GitHub Pages allowlist: `jekyll-paginate`, `jekyll-sitemap`,
`jekyll-seo-tag`, `jekyll-feed`, **`jekyll-include-cache`**. The last one is not optional — see the
`include_cached` gotcha below. Adding any plugin outside the allowlist will fail the Pages build.

## Deployment

- **There is no deploy pipeline in this repo.** Publishing is GitHub's built-in "Deploy from a
  branch" Jekyll build on push to `master` (Pages API: `build_type: legacy`, source
  `master`/`/`). Expect a 1–2 min delay; a failed build leaves the previous site up, silently.
- `.github/workflows/build-check.yml` is the only CI in the repo and **publishes nothing**. It builds
  with `actions/jekyll-build-pages` (the github-pages gem, i.e. production's Jekyll 3.10) and asserts
  that `index.html`, `sitemap.xml`, `feed.xml`, `dark.css` and a rendered post page exist, that sitemap
  `<loc>` values are absolute, that the `custom.css` link is well-formed, and that MM's chrome
  (`class="masthead"`) plus the footer toggle (`id="skin-toggle"`) actually rendered — i.e. the theme
  was used, not a fallback. Keep new assertions there; it is the closest thing to a test suite. It
  builds from `_config.yml` only, since `_config.local.yml` is gitignored.
- After pushing, check both: `gh run list` (the `Build check` workflow **and** `pages-build-deployment`,
  which is the actual deploy) and `gh api repos/oferns/oferns.github.io/pages/builds/latest`.
- **Production runs Jekyll 3.10, local is 4.4.1.** A green local build does not prove the Pages
  build will pass. Minimal Mistakes supports both (`jekyll >= 3.7, < 5.0`), so this is low risk,
  but be conservative with Jekyll-4-only features.
- **Nothing is live until it is committed.** The 2026 reboot sat untracked for weeks and the public
  site kept serving the 2015 page. After adding any file, check `git status` and confirm it is
  staged before pushing.
- No custom domain: Pages reports `cname: null` (the 2015 `www.dotnetinferno.com` CNAME was
  deliberately removed). Don't add a `CNAME` file.

## Gotchas

- `url: "https://oferns.github.io"` in `_config.yml` is **not** cosmetic: with it empty,
  `jekyll-sitemap` emits relative `<loc>` values (invalid) and `jekyll-seo-tag`/`jekyll-feed` emit
  relative canonical, `og:url` and `<id>`. Asset paths use `baseurl`, so setting `url` is safe.
- **`jekyll-include-cache` must be listed in `plugins:` in `_config.yml`.** MM's `_layouts/default.html`
  uses `{% include_cached %}`. Locally the theme gem auto-requires the plugin, so a local build passes
  even with the plugin omitted; Pages requires plugins to be listed explicitly and fails with
  `Liquid syntax error: Unknown tag 'include_cached'`, leaving the previous site live. This bit the
  2026 reboot. Keep it in all three places: `_config.yml`, `_config.local.yml`, `Gemfile`.
- **Repo docs are excluded from the build** (`exclude:` in `_config.yml`). Jekyll renders every
  published `.md` through Liquid, so a `{% ... %}` / `{{ ... }}` example in `AGENTS.md` or `README.md`
  becomes a real tag and fails the build (a literal `{% include_cached %}` in AGENTS.md did exactly
  that). If you add a new root-level markdown file, add it to `exclude:` — and never put Liquid tags
  in published pages without `{% raw %}`.
- The CI/Pages log line `The github-pages gem can't satisfy your Gemfile's dependencies` is expected
  and harmless: the Gemfile pins Jekyll 4.4, the Pages gem pins 3.10. Pages builds with its own gem
  set and ignores the Gemfile. Do not "fix" it by deleting the Gemfile (local dev needs it).
- `_config.yml` references `author.avatar: /assets/images/bio-photo.jpg`, which does not exist.
  Add the image or delete the key.
- `_posts/2026-09-17-hello-world.md` is a setup smoke-test; delete it whenever you like.
- No tests and no linters. Verification = a clean, warning-free local `jekyll build`, the CI smoke
  assertions in `.github/workflows/build-check.yml`, plus eyeballing the rendered page in both light
  and dark skins.
