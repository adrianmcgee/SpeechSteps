/* Tadpole Talk — palette renderer with live WCAG contrast checking.
   Token values are lifted verbatim from the app's Theme.swift. */

(function () {
  "use strict";

  function toLin(c) {
    c /= 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  }
  function lum(hex) {
    const h = hex.replace("#", "").slice(0, 6);
    const r = parseInt(h.slice(0, 2), 16),
      g = parseInt(h.slice(2, 4), 16),
      b = parseInt(h.slice(4, 6), 16);
    return 0.2126 * toLin(r) + 0.7152 * toLin(g) + 0.0722 * toLin(b);
  }
  function ratio(a, b) {
    const L1 = lum(a),
      L2 = lum(b);
    const hi = Math.max(L1, L2),
      lo = Math.min(L1, L2);
    return (hi + 0.05) / (lo + 0.05);
  }

  // role: text | ui | fill | surface
  function badge(tok) {
    if (tok.role === "surface") return { cls: "n", txt: "surface" };
    const r = ratio(tok.hex, tok.on);
    const rr = r.toFixed(2) + ":1";
    if (tok.role === "text") {
      if (r >= 7) return { cls: "aaa", txt: "AAA · " + rr };
      if (r >= 4.5) return { cls: "aa", txt: "AA · " + rr };
      if (r >= 3) return { cls: "lg", txt: "AA Large · " + rr };
      return { cls: "no", txt: "Decorative · " + rr };
    }
    // ui / fill: 3:1 graphics threshold
    if (r >= 3) return { cls: "aa", txt: "AA UI · " + rr };
    return { cls: "no", txt: "Low · " + rr };
  }

  function swatch(tok) {
    const b = badge(tok);
    const onLight = lum(tok.hex) > 0.45;
    const chip = tok.role === "fill"
      ? `<span class="sw-on" style="color:#fff">Aa</span>`
      : tok.role === "surface"
        ? `<span class="sw-on" style="color:${tok.ink || "#1E2A36"}">Aa</span>`
        : "";
    return `
    <div class="sw">
      <div class="sw-chip" style="background:${tok.css || tok.hex};${tok.border ? "box-shadow:inset 0 0 0 1px " + tok.border : ""}">${chip}</div>
      <div class="sw-meta">
        <div class="sw-name">${tok.name}</div>
        <div class="sw-var">${tok.token}</div>
        <div class="sw-hex">${tok.hex}</div>
        <span class="sw-badge ${b.cls}">${b.txt}</span>
      </div>
    </div>`;
  }

  function group(title, note, toks) {
    return `<div class="pal-group">
      <div class="pal-head"><h4>${title}</h4>${note ? `<p>${note}</p>` : ""}</div>
      <div class="sw-grid">${toks.map(swatch).join("")}</div>
    </div>`;
  }

  // ---- LIGHT (“Bright Sky”) ----------------------------------------------
  const LIGHT = {
    surface: "#FFFFFF",
    brand: [
      { name: "Brand", token: "Theme.brand", hex: "#3B82C4", role: "ui", on: "#FFFFFF" },
      { name: "Brand Ink", token: "Theme.brandInk", hex: "#2C649A", role: "text", on: "#FFFFFF" },
      { name: "Accent", token: "Theme.accent", hex: "#F2A03D", role: "fill", on: "#FFFFFF" },
      { name: "Accent Ink", token: "Theme.accentInk", hex: "#D27F1E", role: "text", on: "#FFFFFF" }
    ],
    surf: [
      { name: "Background", token: "Theme.bg", hex: "#F7FBFF", role: "surface", border: "#1B3A5A24", ink: "#1E2A36" },
      { name: "Grouped", token: "Theme.bgGrouped", hex: "#EDF4FB", role: "surface", border: "#1B3A5A24", ink: "#1E2A36" },
      { name: "Card", token: "Theme.card", hex: "#FFFFFF", role: "surface", border: "#1B3A5A24", ink: "#1E2A36" },
      { name: "Fill", token: "Theme.fillQuat", hex: "#1B3A5A", css: "rgba(27,58,90,0.08)", role: "surface", border: "#1B3A5A24", ink: "#1E2A36" },
      { name: "Hairline", token: "Theme.hairline", hex: "#1B3A5A", css: "rgba(27,58,90,0.14)", role: "surface", border: "#1B3A5A24", ink: "#1E2A36" }
    ],
    text: [
      { name: "Label", token: "Theme.label", hex: "#1E2A36", role: "text", on: "#F7FBFF" },
      { name: "Label 2", token: "Theme.label2", hex: "#5A6B7B", role: "text", on: "#FFFFFF" },
      { name: "Label 3", token: "Theme.label3", hex: "#92A2B2", role: "text", on: "#FFFFFF" }
    ],
    sem: [
      { name: "Success", token: "Theme.correct", hex: "#3FA66A", role: "ui", on: "#FFFFFF" },
      { name: "Warning", token: "Theme.approx", hex: "#E9A23B", role: "ui", on: "#FFFFFF" },
      { name: "Try Again", token: "Theme.tryAgain", hex: "#6C8094", role: "ui", on: "#FFFFFF" },
      { name: "Teal", token: "Theme.teal", hex: "#3BA8A0", role: "ui", on: "#FFFFFF" },
      { name: "Pink", token: "Theme.pink", hex: "#D98BA0", role: "ui", on: "#FFFFFF" },
      { name: "Purple", token: "Theme.purple", hex: "#8B7FD0", role: "ui", on: "#FFFFFF" },
      { name: "Error", token: "Theme.red", hex: "#D5694E", role: "ui", on: "#FFFFFF" }
    ]
  };

  // ---- DARK (“Deep Sky”) -------------------------------------------------
  const DARK = {
    brand: [
      { name: "Brand", token: "Theme.brand", hex: "#6FB0E8", role: "ui", on: "#10171F" },
      { name: "Brand Ink", token: "Theme.brandInk", hex: "#9CCBF2", role: "text", on: "#10171F" },
      { name: "Accent", token: "Theme.accent", hex: "#F6B968", role: "ui", on: "#10171F" },
      { name: "Accent Ink", token: "Theme.accentInk", hex: "#F9CB8E", role: "text", on: "#10171F" }
    ],
    surf: [
      { name: "Background", token: "Theme.bg", hex: "#10171F", role: "surface", border: "#FFFFFF1F", ink: "#E8EEF4" },
      { name: "Grouped", token: "Theme.bgGrouped", hex: "#141C26", role: "surface", border: "#FFFFFF1F", ink: "#E8EEF4" },
      { name: "Card", token: "Theme.card", hex: "#1B2530", role: "surface", border: "#FFFFFF1F", ink: "#E8EEF4" },
      { name: "Fill", token: "Theme.fillQuat", hex: "#FFFFFF", css: "rgba(255,255,255,0.08)", role: "surface", border: "#FFFFFF1F", ink: "#E8EEF4" },
      { name: "Hairline", token: "Theme.hairline", hex: "#FFFFFF", css: "rgba(255,255,255,0.12)", role: "surface", border: "#FFFFFF1F", ink: "#E8EEF4" }
    ],
    text: [
      { name: "Label", token: "Theme.label", hex: "#E8EEF4", role: "text", on: "#10171F" },
      { name: "Label 2", token: "Theme.label2", hex: "#9DAFBF", role: "text", on: "#10171F" },
      { name: "Label 3", token: "Theme.label3", hex: "#62748A", role: "text", on: "#1B2530" }
    ],
    sem: [
      { name: "Success", token: "Theme.correct", hex: "#5FC489", role: "ui", on: "#10171F" },
      { name: "Warning", token: "Theme.approx", hex: "#F0BA62", role: "ui", on: "#10171F" },
      { name: "Try Again", token: "Theme.tryAgain", hex: "#8AA0B4", role: "ui", on: "#10171F" },
      { name: "Teal", token: "Theme.teal", hex: "#5FC6BE", role: "ui", on: "#10171F" },
      { name: "Pink", token: "Theme.pink", hex: "#E6A3B5", role: "ui", on: "#10171F" },
      { name: "Purple", token: "Theme.purple", hex: "#A99EE6", role: "ui", on: "#10171F" },
      { name: "Error", token: "Theme.red", hex: "#E2856A", role: "ui", on: "#10171F" }
    ]
  };

  function renderInto(id, data) {
    const el = document.getElementById(id);
    if (!el) return;
    el.innerHTML =
      group("Brand &amp; Accent", "Brand reads as a UI/large-text colour; pair body copy with Brand&nbsp;Ink. Accent is a fill — never set small text in it.", data.brand) +
      group("Surfaces &amp; Neutrals", "", data.surf) +
      group("Text", "Three tiers: primary, secondary, tertiary. Label&nbsp;3 is for hints &amp; large text only.", data.text) +
      group("Semantic", "Used by meaning, never decoration. Shown as solid swatches; in-app they appear as 14% tints behind their own ink.", data.sem);
  }

  function hydrate() {
    renderInto("pal-light", LIGHT);
    renderInto("pal-dark", DARK);
  }

  window.TadpolePalette = { hydrate, ratio };
  if (document.readyState !== "loading") hydrate();
  else document.addEventListener("DOMContentLoaded", hydrate);
})();
