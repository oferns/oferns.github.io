---
title: "Hello world"
date: 2026-09-17
categories: meta
mathjax: true # per-page opt-in; the loader lives in _includes/head/custom.html (the theme has no built-in MathJax)
---

This is a sample post to verify the setup. Delete it whenever you like — just drop new posts into `_posts/` named `YYYY-MM-DD-title.md`.

## Math works

Inline math, e.g. $e^{i\pi} + 1 = 0$, and display math:

$$
\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}
$$

## Code highlighting works

```python
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

That's it — the theme handles the layout, pagination, RSS feed, and search.
