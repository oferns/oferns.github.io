#!/usr/bin/env bash
# Scaffold a new post: scripts/new-post.sh "Post title" [tag1,tag2] [category]
#
# Writes _posts/YYYY-MM-DD-slug.md with front matter matching this site's
# defaults (layout/read_time/related come from _config.yml, so they are omitted).
set -euo pipefail

cd "$(dirname "$0")/.."

title="${1:-}"
if [[ -z "$title" ]]; then
  echo "usage: scripts/new-post.sh \"Post title\" [tag1,tag2] [category]" >&2
  exit 1
fi
tags="${2:-}"
category="${3:-}"

slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
if [[ -z "$slug" ]]; then
  echo "error: title produced an empty slug: '$title'" >&2
  exit 1
fi

date_str="$(date '+%Y-%m-%d %H:%M:%S %z')"
file="_posts/$(date '+%Y-%m-%d')-${slug}.md"

if [[ -e "$file" ]]; then
  echo "error: $file already exists — edit it, don't overwrite" >&2
  exit 1
fi

{
  echo "---"
  echo "title: \"$title\""
  echo "date: $date_str"
  [[ -n "$category" ]] && echo "categories:" && echo "  - $category"
  if [[ -n "$tags" ]]; then
    echo "tags:"
    printf '%s\n' "$tags" | tr ',' '\n' | sed 's/^ *//; s/ *$//' | sed 's/^/  - /'
  fi
  echo "excerpt: \"One or two sentences — used on the home page list and in RSS.\""
  echo "# mathjax: true   # uncomment for \$inline\$ and \$\$display\$\$ math"
  echo "# header:"
  echo "#   teaser: /assets/images/some-image.png   # thumbnail in post lists"
  echo "---"
  echo
  echo "Opening paragraph."
  echo
  echo "<!--more-->"
  echo
  echo "The rest of the post."
  echo
  echo "\`\`\`python"
  echo "def hello():"
  echo "    print(\"highlighted via Rouge\")"
  echo "\`\`\`"
} > "$file"

echo "created $file"
echo "preview: bundle exec jekyll serve --livereload"
