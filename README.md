# oferns.github.io

Personal blog on [GitHub Pages](https://pages.github.com/), built with Jekyll and the [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) theme (loaded remotely — no build tooling needed on GitHub's side).

## Writing a post

Create a file in `_posts/` named `YYYY-MM-DD-title.md`:

```markdown
---
title: "My new post"
date: 2026-09-18
categories: some-category
mathjax: true # optional — loads MathJax for $inline$ and $$display$$ math
---

Body in Markdown. Code blocks get syntax highlighting via Rouge.
```

Push to `master` → GitHub's built-in Jekyll build (Pages "Deploy from a branch", currently
Jekyll 3.10) runs → live at https://oferns.github.io within a minute or two.

This repo has no deploy pipeline of its own. `.github/workflows/build-check.yml` builds with the
real Pages toolchain (`actions/jekyll-build-pages`) purely to catch build failures early — it does
not publish anything.

## Local preview

```sh
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml   # http://localhost:4000
```

(`_config.local.yml` swaps the remote theme for the locally installed gem so no network fetch is
needed; it is gitignored so GitHub Pages never sees it.)

Check for build errors before pushing:

```sh
bundle exec jekyll build --config _config.yml,_config.local.yml
```

A clean build prints no Sass warnings (the theme's Susy noise is silenced via `sass:` in
`_config.yml`).

## Layout

- `_config.yml` — site title, author bio, plugins, pagination (5 posts/page)
- `index.html` — home page using the theme's `home` layout (post list + profile sidebar)
- `_posts/` — blog posts
- `_includes/head/custom.html` — MathJax loader (theme hook; per-page opt-in via front matter) plus
  the dark-stylesheet preload
- `_includes/footer/custom.html` — light/dark mode toggle
- `assets/css/dark.scss` — second full compile of the theme in the dark skin, toggled at runtime
- `assets/css/custom.css` — styles that must work in both skins
- `Gemfile` / `_config.local.yml` — local dev only
- `AGENTS.md` — conventions and gotchas for AI assistants working on this repo
