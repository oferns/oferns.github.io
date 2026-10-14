# oferns.github.io

Personal blog on [GitHub Pages](https://pages.github.com/). [Jekyll](https://jekyllrb.com/) 4.4 +
the [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) theme as a **gem**, built and
deployed by a GitHub Actions workflow (no legacy Pages build, no `remote_theme`).

## Quick start

```sh
ruby -v          # .ruby-version pins 3.4.3
bundle install
rake serve       # http://localhost:4000 with live reload
```

## Writing a post

```sh
rake new TITLE="My new post" TAGS=jekyll,math CATEGORY=math
# or: scripts/new-post.sh "My new post" jekyll,math math
```

That writes `_posts/YYYY-MM-DD-slug.md` with the right front matter. `layout`, `read_time`,
`related` and `author_profile` come from `defaults:` in `_config.yml`, so don't repeat them.

```markdown
---
title: "My new post"
date: 2026-10-14 09:30:00 +0100
categories:
  - math
tags:
  - linear-algebra
excerpt: "One or two sentences — used on the home page list and in RSS."
mathjax: true # optional — $inline$ and $$display$$ math (per-page opt-in)
# header:
#   teaser: /assets/images/pic.png # thumbnail in post lists
---

Intro paragraph. `<!--more-->` controls where the home-page preview cuts off.
```

Code blocks are highlighted by Rouge; Markdown is kramdown with GFM input.

## Commands

| Task | Command |
|---|---|
| Dev server + live reload | `rake serve` |
| Build to `_site` | `rake build` |
| Build + smoke assertions (what CI runs) | `rake check` |
| Scaffold a post | `rake new TITLE="…" [TAGS=…] [CATEGORY=…]` |
| Update all gems within the Gemfile constraints | `rake update` (then `rake check`) |

## Deploy

Push to `master` → `.github/workflows/deploy.yml` builds with this Gemfile, runs
`scripts/check.sh`, uploads the artifact and deploys it to Pages. Pull requests get the same build
and assertions, without the deploy.

```sh
gh run list                                              # build + deploy status
gh run view <id> --log                                   # failure output
```

Pages must be configured with **GitHub Actions** as its build source (Settings → Pages →
Build and deployment → Source: GitHub Actions). If it is ever switched back to "Deploy from a
branch", the legacy Jekyll 3.10 toolchain returns and this repo's Gemfile is ignored.

## Layout

- `_config.yml` — theme, author bio, features (search, reading time, related, archives), plugins,
  front matter defaults, pagination, Sass noise suppression, `exclude:`
- `_data/navigation.yml` — masthead links (overrides the theme's placeholder nav)
- `index.html` — home page: theme `home` layout, paginated post list + author profile
- `_posts/` — posts
- `search.md` `/search/` — lunr site search · `categories.md` `/categories/` · `tags.md` `/tags/` ·
  `404.md` `/404.html`
- `_includes/head/custom.html` — MathJax loader (pinned + SRI) and the dark-skin preload
- `_includes/footer/custom.html` — light/dark toggle (persisted in `localStorage`)
- `assets/css/dark.scss` — second compile of the theme in the dark skin · `assets/css/custom.css` —
  styles that must work in both skins
- `scripts/check.sh` — smoke assertions, shared by `rake check` and CI
- `scripts/new-post.sh` — post scaffolder
- `Rakefile` — the task runner behind all of the above
- `.github/workflows/deploy.yml` — build + deploy · `.github/dependabot.yml` — weekly gem/action bumps
- `AGENTS.md` — conventions and gotchas for AI assistants
