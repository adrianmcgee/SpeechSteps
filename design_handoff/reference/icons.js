/* Tadpole Talk — app icon + mascot builder.
   Everything is drawn in a 0..100 SVG space and rendered at any size, so it stays
   crisp from 1024 down to 60px. Three mascot directions, three iOS variants. */

(function () {
  "use strict";

  // iOS continuous-corner squircle, ~22.37% radius, as a normalized 0..100 path.
  // (A real superellipse, not a plain rounded rect — reads correctly as an app icon.)
  const SQUIRCLE =
    "M50,0 C8.9,0 0,8.9 0,50 C0,91.1 8.9,100 50,100 C91.1,100 100,91.1 100,50 C100,8.9 91.1,0 50,0 Z";

  // ---- Color schemes ------------------------------------------------------
  const SCHEMES = {
    light: {
      bgTop: "#7FCBDC", bgBot: "#3B7FC4",
      glow: "#EAF8FF",
      body: "#235C90", bodyEdge: "#1B4A77",
      belly: "#EAF6FF",
      eyeW: "#FFFFFF", eyeD: "#16344E",
      cheek: "#F4A24A",
      smile: "#16344E",
      bub: "#FFFFFF", bubAccent: "#F6B968",
      ring: "none"
    },
    dark: {
      bgTop: "#1C3349", bgBot: "#0C1622",
      glow: "#23476A",
      body: "#6FB0E8", bodyEdge: "#5A97CC",
      belly: "#CDE6FA",
      eyeW: "#EAF3FB", eyeD: "#0C1622",
      cheek: "#F6B968",
      smile: "#0C1622",
      bub: "#9CC7EC", bubAccent: "#F6B968",
      ring: "#6FB0E8"
    },
    tinted: {
      // Grayscale on dark — the OS applies the user's chosen tint over this.
      bgTop: "#2B2B2D", bgBot: "#161617",
      glow: "#3A3A3C",
      body: "#C9CACC", bodyEdge: "#A9AAAC",
      belly: "#ECEDEF",
      eyeW: "#F2F3F5", eyeD: "#161617",
      cheek: "#9A9B9D",
      smile: "#161617",
      bub: "#DADBDD", bubAccent: "#DADBDD",
      ring: "none"
    }
  };

  // ---- Mascot directions --------------------------------------------------
  // Each returns the inner markup of the tadpole, drawn in 0..100, given a scheme.
  function tadClassic(s) {
    return `
      <path d="M55 47 C70 35 80 31 92 23 C88 38 93 49 84 59 C76 66 63 63 56 58 Z"
            fill="${s.body}"/>
      <circle cx="44" cy="55" r="22" fill="${s.body}"/>
      <ellipse cx="39" cy="63" rx="13.5" ry="10.5" fill="${s.belly}"/>
      <circle cx="29" cy="59" r="4.2" fill="${s.cheek}" opacity="0.55"/>
      <circle cx="40.5" cy="49" r="7.6" fill="${s.eyeW}"/>
      <circle cx="43" cy="50" r="3.7" fill="${s.eyeD}"/>
      <circle cx="41.3" cy="47.6" r="1.5" fill="#fff"/>
      <path d="M31 61 Q39 68 47 60" stroke="${s.smile}" stroke-width="2.4"
            fill="none" stroke-linecap="round"/>`;
  }

  function tadPeek(s) {
    // Chubbier, two forward eyes, short curled tail — "peeking out of the pond".
    return `
      <path d="M58 50 C71 44 80 46 90 40 C85 52 88 60 79 64 C72 67 62 64 57 60 Z"
            fill="${s.body}"/>
      <circle cx="45" cy="55" r="24" fill="${s.body}"/>
      <ellipse cx="41" cy="64" rx="15" ry="11" fill="${s.belly}"/>
      <circle cx="30" cy="60" r="4.4" fill="${s.cheek}" opacity="0.55"/>
      <circle cx="58" cy="60" r="4.4" fill="${s.cheek}" opacity="0.4"/>
      <circle cx="37" cy="49" r="6.4" fill="${s.eyeW}"/>
      <circle cx="51" cy="49" r="6.4" fill="${s.eyeW}"/>
      <circle cx="38.6" cy="50" r="3.1" fill="${s.eyeD}"/>
      <circle cx="52.6" cy="50" r="3.1" fill="${s.eyeD}"/>
      <circle cx="37.4" cy="48.6" r="1.2" fill="#fff"/>
      <circle cx="51.4" cy="48.6" r="1.2" fill="#fff"/>
      <path d="M39 60 Q45 65 51 60" stroke="${s.smile}" stroke-width="2.4"
            fill="none" stroke-linecap="round"/>`;
  }

  function tadSwim(s) {
    // Dynamic swimmer: tilted body, wavy tail, happy closed eye, motion bubbles.
    return `
      <g transform="rotate(-10 46 54)">
        <path d="M56 50 C72 44 78 52 90 50 C82 58 88 66 76 68 C70 69 60 64 56 60 Z"
              fill="${s.body}"/>
        <circle cx="44" cy="54" r="21" fill="${s.body}"/>
        <ellipse cx="39" cy="61" rx="13" ry="10" fill="${s.belly}"/>
        <circle cx="29" cy="57" r="4" fill="${s.cheek}" opacity="0.55"/>
        <path d="M35 49 Q40 44 45 49" stroke="${s.eyeD}" stroke-width="2.6"
              fill="none" stroke-linecap="round"/>
        <path d="M32 59 Q39 65 46 58" stroke="${s.smile}" stroke-width="2.4"
              fill="none" stroke-linecap="round"/>
      </g>`;
  }

  const TADS = { classic: tadClassic, peek: tadPeek, swim: tadSwim };

  // ---- Icon assembly ------------------------------------------------------
  function buildIcon(opts) {
    const o = opts || {};
    const scheme = SCHEMES[o.scheme || "light"];
    const tad = TADS[o.variant || "classic"];
    const size = o.size || 120;
    const uid = "ic" + Math.random().toString(36).slice(2, 8);

    const ring = scheme.ring !== "none"
      ? `<circle cx="44" cy="54" r="30" fill="none" stroke="${scheme.ring}" stroke-width="1.4" opacity="0.25"/>`
      : "";

    // Soft pond bubbles (kept large & sparse so they survive at 60px).
    const bubbles = `
      <circle cx="74" cy="78" r="3.2" fill="${scheme.bub}" opacity="0.5"/>
      <circle cx="82" cy="70" r="2.0" fill="${scheme.bub}" opacity="0.4"/>
      <circle cx="20" cy="30" r="2.6" fill="${scheme.bubAccent}" opacity="0.85"/>`;

    return `
<svg class="appicon" viewBox="0 0 100 100" width="${size}" height="${size}"
     role="img" aria-label="Tadpole Talk app icon" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="${uid}g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="${scheme.bgTop}"/>
      <stop offset="1" stop-color="${scheme.bgBot}"/>
    </linearGradient>
    <radialGradient id="${uid}r" cx="0.5" cy="0.42" r="0.62">
      <stop offset="0" stop-color="${scheme.glow}" stop-opacity="0.55"/>
      <stop offset="1" stop-color="${scheme.glow}" stop-opacity="0"/>
    </radialGradient>
    <clipPath id="${uid}c"><rect width="100" height="100" rx="22.5" ry="22.5"/></clipPath>
  </defs>
  <g clip-path="url(#${uid}c)">
    <rect width="100" height="100" fill="url(#${uid}g)"/>
    <ellipse cx="50" cy="44" rx="62" ry="50" fill="url(#${uid}r)"/>
    ${bubbles}
    ${ring}
    ${tad(scheme)}
  </g>
</svg>`;
  }

  // Standalone mascot (no background) for in-app / wordmark use.
  function buildMascot(opts) {
    const o = opts || {};
    const scheme = SCHEMES[o.scheme || "light"];
    const tad = TADS[o.variant || "classic"];
    const size = o.size || 80;
    return `
<svg class="mascot" viewBox="0 0 100 100" width="${size}" height="${size}"
     role="img" aria-label="Tadpole mascot" xmlns="http://www.w3.org/2000/svg">
  ${tad(scheme)}
</svg>`;
  }

  // Render into any [data-icon] / [data-mascot] placeholder.
  function hydrate(root) {
    (root || document).querySelectorAll("[data-icon]").forEach((el) => {
      el.innerHTML = buildIcon({
        scheme: el.dataset.scheme,
        variant: el.dataset.variant,
        size: +el.dataset.size || 120
      });
    });
    (root || document).querySelectorAll("[data-mascot]").forEach((el) => {
      el.innerHTML = buildMascot({
        scheme: el.dataset.scheme,
        variant: el.dataset.variant,
        size: +el.dataset.size || 80
      });
    });
  }

  window.TadpoleIcons = { buildIcon, buildMascot, hydrate, SCHEMES };
  if (document.readyState !== "loading") hydrate();
  else document.addEventListener("DOMContentLoaded", () => hydrate());
})();
