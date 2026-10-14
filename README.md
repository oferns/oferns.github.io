# oferns.github.io

Personal blog on [GitHub Pages](https://pages.github.com/). Plain [Jekyll](https://jekyllrb.com/)
4.4 — **no theme gem, no CSS framework, no icon font, no jQuery** — built and deployed by a GitHub
Actions workflow.

The whole page payload is ~4 KB of gzipped CSS + JS. Dark mode is a CSS custom-property swap, code
highlighting is a generated Rouge stylesheet, icons are inline SVG, search is a JSON file plus ~60
lines of vanilla JS.

## Quick start

```sh
ruby -v          # .ruby-version pins 3.4.3
bundle install
rake serve       # http://localhost:4000 with live reload
```

## Writing a post

```sh
rake new TITLE="My new post" TAGS=jekyll,math CATEGORY=math
```

writes `_posts/YYYY-MM-DD-slug.md`:

```markdown
---
title: "My new post"
date: 2026-10-14 09:30:00 +0100
categories:
  - math
tags:
  - linear-algebra
excerpt: "One or two sentences — used on the home page list and in RSS."
mathjax: true # optional — $inline$ and $$display$$ math, loaded only on this page
---

Intro paragraph. `<!--more-->` marks where the excerpt cuts.
```

`layout: post` comes from `defaults:` in `_config.yml` — don't repeat it. Markdown is kramdown with
GFM input; code blocks are highlighted by Rouge.

## Commands

| Task | Command |
|---|---|
| Dev server + live reload | `rake serve` |
| Build to `_site` | `rake build` |
| Build + smoke assertions (what CI runs) | `rake check` |
| Scaffold a post | `rake new TITLE="…" [TAGS=a,b] [CATEGORY=math]` |
| Regenerate the code-highlighting CSS | `rake highlight` |
| Update all gems within the Gemfile constraints | `rake update` (then `rake check`) |

## Deploy

Push to `master` → `.github/workflows/deploy.yml` runs `bundle exec jekyll build`, then
`scripts/check.sh`, then uploads the artifact and deploys it to Pages. Pull requests get the build
and the assertions, without the deploy.

```sh
gh run list                              # build + deploy status
gh run view <id> --log                   # failure output
```

Pages must use **GitHub Actions** as its build source (Settings → Pages → Source: GitHub Actions).

## How it's put together

- `_config.yml` — site meta, `permalink` (pins today's URL shape), plugins, front matter defaults,
  `home_post_limit`, `reading_time_wpm`, `exclude:`
- `_layouts/default.html` — head, nav, footer, pre-paint theme script, MathJax opt-in
- `_layouts/home.html` — post list · `_layouts/post.html` — article, tags, prev/next, related
- `_includes/icon.html` — inline SVG icons (`{% include icon.html name="moon" %}`)
- `_includes/mathjax.html` — pinned + SRI'd MathJax
- `assets/css/main.css` — design tokens (light/dark), typography, layout. Edit this for any style change.
- `assets/css/highlight.css` — **generated** by `rake highlight`; don't hand-edit
- `assets/js/theme.js` — theme toggle + copy-code buttons · `assets/js/search.js` — search page logic
- `search.json` — the search index, generated at build time
- `index.html` `404.md` `categories.md` `tags.md` `search.md` — the pages
- `scripts/check.sh` — smoke assertions, shared by `rake check` and CI
- `scripts/new-post.sh` `scripts/gen-highlight.rb` — scaffolders
- `.github/workflows/deploy.yml` — build + deploy · `.github/dependabot.yml` — weekly bumps
- `AGENTS.md` — conventions and gotchas for AI assistants

## Deliberately absent

Font Awesome (10 icons → inline SVG), jQuery + its plugins, lunr, a second "dark" stylesheet,
Minimal Mistakes and its dependency tree (`jekyll-gist`, `octokit`, `faraday`, …),
`jekyll-paginate` (the home page lists posts directly). Re-adding any of them fails `scripts/check.sh`.
