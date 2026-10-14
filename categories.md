---
title: Categories
permalink: /categories/
---
# Categories

<ul class="taxonomy">
  {%- for c in site.categories -%}
  <li><a href="#{{ c[0] | slugify }}">{{ c[0] }}</a> <span class="count">{{ c[1] | size }}</span></li>
  {%- endfor -%}
</ul>

{%- for c in site.categories -%}
<section id="{{ c[0] | slugify }}">
  <h2>{{ c[0] }}</h2>
  <ul class="post-list">
    {%- for p in c[1] -%}
    <li>
      <h2><a href="{{ p.url | relative_url }}">{{ p.title }}</a></h2>
      <p class="meta">{{ p.date | date: "%-d %B %Y" }}</p>
    </li>
    {%- endfor -%}
  </ul>
</section>
{%- endfor -%}
