/**
 * Doc Truyen UX — mobile nav, search, reader tools, TOC, comments.
 */
(function () {
  "use strict";

  var STORAGE_KEY = "doctruyen_reader_prefs_v1";
  var prefs = loadPrefs();

  function loadPrefs() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : {};
    } catch (e) {
      return {};
    }
  }

  function savePrefs() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs));
    } catch (e) {
      /* ignore quota / private mode */
    }
  }

  function qs(sel, root) {
    return (root || document).querySelector(sel);
  }

  function qsa(sel, root) {
    return Array.prototype.slice.call((root || document).querySelectorAll(sel));
  }

  /* ---------- Header: menu + search ---------- */
  function initHeader() {
    var toggle = qs(".dt-nav-toggle");
    var searchToggle = qs(".dt-search-toggle");
    var searchPanel = qs(".dt-header-search");
    var nav = qs("#site-navigation");
    var backdrop = qs(".dt-nav-backdrop");

    function setBackdrop(open) {
      if (!backdrop) return;
      if (open) {
        backdrop.removeAttribute("hidden");
        backdrop.setAttribute("aria-hidden", "false");
      } else {
        backdrop.setAttribute("hidden", "hidden");
        backdrop.setAttribute("aria-hidden", "true");
      }
    }

    function closeNav() {
      document.body.classList.remove("is-nav-open");
      if (toggle) toggle.setAttribute("aria-expanded", "false");
      setBackdrop(false);
    }

    function openNav() {
      document.body.classList.add("is-nav-open");
      if (toggle) toggle.setAttribute("aria-expanded", "true");
      if (searchPanel) searchPanel.classList.remove("is-open");
      setBackdrop(true);
    }

    if (toggle) {
      toggle.addEventListener("click", function () {
        if (document.body.classList.contains("is-nav-open")) {
          closeNav();
        } else {
          openNav();
        }
      });
    }

    if (backdrop) {
      backdrop.addEventListener("click", closeNav);
    }

    if (nav) {
      nav.addEventListener("click", function (e) {
        if (e.target && e.target.tagName === "A" && window.matchMedia("(max-width: 900px)").matches) {
          closeNav();
        }
      });
    }

    if (searchToggle && searchPanel) {
      searchToggle.addEventListener("click", function () {
        var open = searchPanel.classList.toggle("is-open");
        searchToggle.setAttribute("aria-expanded", open ? "true" : "false");
        closeNav();
        if (open) {
          var input = qs("input[type='text'], input[name='s']", searchPanel);
          if (input) input.focus();
        }
      });
    }
  }

  /* ---------- Reading progress ---------- */
  function initProgress() {
    var bar = qs(".reading-progress__bar");
    var content = qs(".entry-content");
    if (!bar || !content) return;

    function update() {
      var rect = content.getBoundingClientRect();
      var total = content.offsetHeight - window.innerHeight;
      if (total <= 0) {
        bar.style.width = "100%";
        return;
      }
      var scrolled = Math.min(Math.max(-rect.top, 0), total);
      var pct = (scrolled / total) * 100;
      bar.style.width = pct.toFixed(2) + "%";
    }

    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    update();
  }

  /* ---------- TOC from headings ---------- */
  function slugify(text) {
    return String(text || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9\s-]/g, "")
      .trim()
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .slice(0, 60) || "muc";
  }

  function initToc() {
    var content = qs(".entry-content");
    var host = qs(".reader-toc");
    if (!content || !host) return;

    var headings = qsa("h2, h3", content).filter(function (h) {
      return h.textContent && h.textContent.trim().length > 0;
    });

    if (!headings.length) {
      host.hidden = true;
      return;
    }

    var list = document.createElement("ol");
    var used = {};

    headings.forEach(function (h, i) {
      var base = slugify(h.textContent);
      var id = base;
      var n = 2;
      while (used[id] || document.getElementById(id)) {
        id = base + "-" + n;
        n += 1;
      }
      used[id] = true;
      if (!h.id) h.id = id;

      var li = document.createElement("li");
      var a = document.createElement("a");
      a.href = "#" + h.id;
      a.textContent = h.textContent.trim();
      li.appendChild(a);
      list.appendChild(li);
    });

    var existing = qs("ol", host);
    if (existing) existing.remove();
    host.appendChild(list);
    host.hidden = false;
  }

  /* ---------- Reader prefs / toolbar ---------- */
  function applyPrefs() {
    var theme = prefs.theme || "light";
    document.body.classList.remove("reader-theme-paper", "reader-theme-dark");
    if (theme === "paper") document.body.classList.add("reader-theme-paper");
    if (theme === "dark") document.body.classList.add("reader-theme-dark");

    var size = prefs.fontSize || 18;
    document.documentElement.style.setProperty("--reader-font-size", size + "px");

    var width = prefs.width || "normal";
    var max =
      width === "wide" ? "100%" : width === "narrow" ? "720px" : "100%";
    if (window.matchMedia("(max-width: 900px)").matches) {
      max = "100%";
    }
    document.documentElement.style.setProperty("--reader-max-width", max);

    qsa(".reader-toolbar [data-theme]").forEach(function (btn) {
      btn.classList.toggle("is-active", btn.getAttribute("data-theme") === theme);
    });
    qsa(".reader-toolbar [data-width]").forEach(function (btn) {
      btn.classList.toggle("is-active", btn.getAttribute("data-width") === width);
    });
  }

  function initToolbar() {
    var toolbar = qs(".reader-toolbar");
    if (!toolbar) return;

    applyPrefs();

    toolbar.addEventListener("click", function (e) {
      var btn = e.target.closest("button");
      if (!btn) return;

      if (btn.hasAttribute("data-font")) {
        var delta = btn.getAttribute("data-font") === "plus" ? 1 : -1;
        var size = Math.min(24, Math.max(15, (prefs.fontSize || 18) + delta));
        prefs.fontSize = size;
        savePrefs();
        applyPrefs();
      }

      if (btn.hasAttribute("data-theme-cycle")) {
        var order = ["light", "paper", "dark"];
        var cur = prefs.theme || "light";
        var idx = order.indexOf(cur);
        prefs.theme = order[(idx + 1) % order.length];
        savePrefs();
        applyPrefs();
      }

      if (btn.hasAttribute("data-width-cycle")) {
        var widths = ["narrow", "normal", "wide"];
        var w = prefs.width || "normal";
        var wi = widths.indexOf(w);
        prefs.width = widths[(wi + 1) % widths.length];
        savePrefs();
        applyPrefs();
      }

      if (btn.hasAttribute("data-top")) {
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
    });

    var lastY = window.scrollY;
    var ticking = false;
    window.addEventListener(
      "scroll",
      function () {
        if (ticking) return;
        ticking = true;
        window.requestAnimationFrame(function () {
          var y = window.scrollY;
          if (y > lastY + 12 && y > 120) {
            toolbar.classList.add("is-collapsed");
          } else if (y < lastY - 8) {
            toolbar.classList.remove("is-collapsed");
          }
          lastY = y;
          ticking = false;
        });
      },
      { passive: true }
    );
  }

  /* ---------- Comments: collapse form ---------- */
  function initComments() {
    var area = qs(".comments-area");
    if (!area) return;

    var respond = qs(".comment-respond", area);
    if (!respond) return;

    // Avoid double toggle if already injected.
    if (qs(".comment-form-toggle", area)) return;

    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "comment-form-toggle";
    var openLabel =
      (window.doctruyenUx && doctruyenUx.i18n && doctruyenUx.i18n.writeComment) ||
      "Viết bình luận";
    var hideLabel =
      (window.doctruyenUx && doctruyenUx.i18n && doctruyenUx.i18n.hideComment) ||
      "Ẩn form bình luận";
    btn.textContent = openLabel;

    respond.classList.add("is-collapsed");
    respond.parentNode.insertBefore(btn, respond);

    btn.addEventListener("click", function () {
      var collapsed = respond.classList.toggle("is-collapsed");
      btn.textContent = collapsed ? openLabel : hideLabel;
      if (!collapsed) {
        var field = qs("textarea, input[type='text']", respond);
        if (field) field.focus();
      }
    });

    // Soft-hide duplicate native comment form if wpDiscuz also rendered one.
    var forms = qsa(".comment-respond", area);
    if (forms.length > 1 && qs("#wpdcom")) {
      forms.forEach(function (form, i) {
        if (i > 0 && !form.closest("#wpdcom")) {
          form.style.display = "none";
        }
      });
      btn.style.display = "none";
    }
  }

  /* ---------- Page / chapter jump selects (URL template) ---------- */
  function initPageJumpSelects() {
    var selects = qsa("select.chapter-jump, select.archive-pagination__select");
    selects.forEach(function (select) {
      select.addEventListener("change", function () {
        var page = String(select.value || "");
        if (!page) return;
        var tpl = select.getAttribute("data-url-tpl") || "";
        var url1 = select.getAttribute("data-url-page1") || "";
        var token = select.getAttribute("data-page-token") || "999999";
        var url = page === "1" && url1 ? url1 : tpl.split(token).join(page);
        if (url) window.location.href = url;
      });
    });
  }

  /* ---------- View counter (async, localStorage — không Set-Cookie PHP) ---------- */
  function initViewTrack() {
    var cfg = window.doctruyenUx || {};
    var postId = cfg.viewPostId | 0;
    var ajaxUrl = cfg.ajaxUrl;
    if (!postId || !ajaxUrl) return;

    var key = "dt_pv_" + postId;
    var now = new Date().getTime();
    var ttl = Math.max(60, cfg.viewTtl | 0 || 900) * 1000;
    try {
      if (window.localStorage) {
        var last = parseInt(localStorage.getItem(key), 10);
        if (last && now - last < ttl) return;
        localStorage.setItem(key, String(now));
      }
    } catch (e) {}

    var body = "action=doctruyen_track_view&post_id=" + encodeURIComponent(String(postId));
    if (window.fetch) {
      fetch(ajaxUrl, {
        method: "POST",
        credentials: "same-origin",
        headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
        body: body,
      }).catch(function () {});
      return;
    }

    var xhr = new XMLHttpRequest();
    xhr.open("POST", ajaxUrl, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
    xhr.send(body);
  }

  document.addEventListener("DOMContentLoaded", function () {
    initHeader();
    initPageJumpSelects();
    initProgress();
    initToc();
    initToolbar();
    initComments();
    initViewTrack();
  });
})();
