---
title: Tags
permalink: /tags/
---
# Tags

<ul class="taxonomy">
  {%- for t in site.tags -%}
  <li><a href="#{{ t[0] | slugify }}">{{ t[0] }}</a> <span class="count">{{ t[1] | size }}</span></li>
  {%- endfor -%}
</ul>

{%- for t in site.tags -%}
<section id="{{ t[0] | slugify }}">
  <h2>{{ t[0] }}</h2>
  <ul class="post-list">
    {%- for p in t[1] -%}
    <li>
      <h2><a href="{{ p.url | relative_url }}">{{ p.title }}</a></h2>
      <p class="meta">{{ p.date | date: "%-d %B %Y" }}</p>
    </li>
    {%- endfor -%}
  </ul>
</section>
{%- endfor -%}
