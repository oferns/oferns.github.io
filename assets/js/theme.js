// Theme toggle (CSS custom properties, no stylesheet swap) + copy buttons on code blocks.
(function () {
  var KEY = "skin";
  var root = document.documentElement;

  // ---- light/dark -------------------------------------------------------
  var btn = document.getElementById("skin-toggle");
  function stored() { try { return localStorage.getItem(KEY); } catch (e) { return null; } }
  function isDark() { return root.getAttribute("data-theme") === "dark"; }
  function render() {
    if (!btn) return;
    btn.querySelector(".moon").style.display = isDark() ? "none" : "";
    btn.querySelector(".sun").style.display = isDark() ? "" : "none";
    btn.setAttribute("aria-pressed", String(isDark()));
  }
  render(); // the <head> script already applied the theme before paint
  if (btn) {
    btn.addEventListener("click", function () {
      root.setAttribute("data-theme", isDark() ? "light" : "dark");
      try { localStorage.setItem(KEY, root.getAttribute("data-theme")); } catch (e) {}
      render();
    });
  }
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function (e) {
    if (stored()) return; // explicit user choice wins
    root.setAttribute("data-theme", e.matches ? "dark" : "light");
    render();
  });

  // ---- copy buttons on code blocks --------------------------------------
  var blocks = document.querySelectorAll(".highlight");
  blocks.forEach(function (block) {
    var pre = block.querySelector("pre");
    if (!pre) return;
    var b = document.createElement("button");
    b.type = "button";
    b.className = "copy-btn";
    b.textContent = "Copy";
    b.addEventListener("click", function () {
      var text = pre.innerText;
      var done = function () {
        b.textContent = "Copied";
        setTimeout(function () { b.textContent = "Copy"; }, 1500);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, function () { b.textContent = "Failed"; });
      } else {
        var ta = document.createElement("textarea");
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand("copy"); done(); } catch (err) { b.textContent = "Failed"; }
        document.body.removeChild(ta);
      }
    });
    block.appendChild(b);
  });
})();
