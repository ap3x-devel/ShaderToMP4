/* SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET */
(function () {
  'use strict';
  var html = document.documentElement;
  var root = html.getAttribute('data-root') || '';

  // Langue : memorisee dans le navigateur de la personne, jamais envoyee
  var btn = document.getElementById('langBtn');
  function apply(l) {
    html.lang = l;
    try { localStorage.setItem('stm-lang', l); } catch (e) {}
    if (btn) btn.textContent = l === 'fr' ? 'FR | EN' : 'EN | FR';
    var t = html.getAttribute('data-title-' + l);
    if (t) document.title = t;
    var hero = document.getElementById('hero');
    if (hero) hero.src = root + 'screenshots/' + l + '/done.png';
    document.querySelectorAll('img[data-shot]').forEach(function (i) { i.src = root + 'screenshots/' + l + '/' + i.getAttribute('data-shot') + '.png'; });
    document.dispatchEvent(new CustomEvent('stm-lang', { detail: l }));
  }
  // Une ancre qui vise la ligne de l'autre langue (cachee) est reportee sur son jumeau « fr- »
  function jump() {
    var id = decodeURIComponent((location.hash || '').replace('#', ''));
    if (!id) return;
    var el = document.getElementById(id);
    if (el && el.offsetParent !== null) return;
    var twin = document.getElementById(html.lang === 'fr' ? 'fr-' + id : id.replace(/^fr-/, ''));
    if (twin && twin.offsetParent !== null) twin.scrollIntoView();
  }
  window.addEventListener('hashchange', jump);
  document.addEventListener('stm-lang', jump);
  var saved = null;
  try { saved = localStorage.getItem('stm-lang'); } catch (e) {}
  apply(saved || ((navigator.language || 'en').toLowerCase().indexOf('fr') === 0 ? 'fr' : 'en'));
  if (btn) btn.addEventListener('click', function () { apply(html.lang === 'fr' ? 'en' : 'fr'); });

  // Agrandissement des captures
  var box = document.getElementById('lightbox');
  if (box) {
    var big = box.querySelector('img');
    var close = function () { box.classList.remove('open'); };
    document.addEventListener('click', function (e) {
      var t = e.target;
      if (t.tagName === 'IMG' && (t.id === 'hero' || t.closest('.two, .gallery'))) { big.src = t.currentSrc || t.src; big.alt = t.alt; box.classList.add('open'); }
      else if (box.classList.contains('open')) close();
    });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
  }

  // Filtre de la galerie : des boutons a bascule, la liste complete reste lisible sans script
  var chips = document.querySelectorAll('.chip[data-cat]');
  if (chips.length) {
    var items = document.querySelectorAll('.thumbs li[data-cat]');
    var count = document.getElementById('galleryCount');
    var show = function (cat) {
      var n = 0;
      items.forEach(function (li) { var ok = cat === '' || li.getAttribute('data-cat') === cat; li.hidden = !ok; if (ok) n++; });
      chips.forEach(function (c) { c.setAttribute('aria-pressed', c.getAttribute('data-cat') === cat ? 'true' : 'false'); });
      if (count) count.textContent = n;
    };
    chips.forEach(function (c) { c.addEventListener('click', function () { show(c.getAttribute('data-cat')); }); });
    var wanted = (location.hash || '').replace('#', '');
    show(document.querySelector('.chip[data-cat="' + wanted + '"]') ? wanted : '');
  }

  // Recherche locale : l'index est un fichier du site (assets/search-data.js), rien n'est envoye
  var form = document.getElementById('searchForm');
  if (form && window.STM_INDEX) {
    var input = document.getElementById('q'), out = document.getElementById('results'), status = document.getElementById('searchStatus');
    var fold = function (s) { return s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, ''); };
    var esc = function (s) { return s.replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); };
    var kinds = { guide: ['Guide', 'Guide'], gallery: ['Example', 'Exemple'], reference: ['Reference', 'Référence'] };
    var run = function () {
      var lang = html.lang === 'fr' ? 'fr' : 'en', li = lang === 'fr' ? 1 : 0;
      var words = fold(input.value).split(/\s+/).filter(Boolean);
      out.innerHTML = '';
      if (!words.length) { status.textContent = ''; return; }
      var found = [];
      window.STM_INDEX.forEach(function (p) {
        var title = fold(p.t[lang]), text = fold(p.x[lang]), score = 0;
        for (var i = 0; i < words.length; i++) {
          var inT = title.indexOf(words[i]) >= 0, inX = text.indexOf(words[i]) >= 0;
          if (!inT && !inX) return;
          score += (inT ? 10 : 0) + (inX ? 1 : 0);
        }
        var at = text.indexOf(words[0]), snip = '';
        if (at >= 0) {
          var from = Math.max(0, at - 60), raw = p.x[lang].substring(from, from + 190);
          snip = (from > 0 ? '… ' : '') + esc(raw) + ' …';
          words.forEach(function (w) { snip = snip.replace(new RegExp('(' + w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'ig'), '<mark>$1</mark>'); });
        }
        found.push({ p: p, score: score, snip: snip });
      });
      found.sort(function (a, b) { return b.score - a.score; });
      found.slice(0, 40).forEach(function (f) {
        var item = document.createElement('li');
        item.innerHTML = '<a href="' + root + f.p.u + '">' + esc(f.p.t[lang]) + '</a><span class="kind">' + kinds[f.p.k][li] + '</span>' + (f.snip ? '<p>' + f.snip + '</p>' : '');
        out.appendChild(item);
      });
      status.textContent = found.length ? (lang === 'fr' ? found.length + ' résultat(s)' : found.length + ' result(s)') : (lang === 'fr' ? 'Aucun résultat' : 'No result');
    };
    form.addEventListener('submit', function (e) { e.preventDefault(); run(); });
    input.addEventListener('input', run);
    document.addEventListener('stm-lang', run);
    var q = new URLSearchParams(location.search).get('q');
    if (q) input.value = q;
    run();
  }
})();
