import SwiftUI

/// An original, generated mouth-position diagram. Drawn entirely with SwiftUI shapes — so it
/// ships no licensed cue artwork, scales crisply, and adapts to light/dark automatically.
///
/// It's a **side cross-section** (the standard speech-therapy sagittal view): a left-facing
/// head cut open so a parent can see the lips, teeth, tongue and roof of the mouth — and,
/// crucially, *where the tongue goes*, which can't be seen front-on in a mirror. The part that
/// makes the sound is filled in the brand colour; a motion glyph shows the action (a pop, a
/// long stream of air, a hum out the nose, a glide); voiced sounds get a throat-buzz mark.
struct MouthDiagram: View {
    let phoneme: Phoneme

    /// Controls how much text the diagram carries, sized to its container.
    /// `.compact` (library grid, ~84pt) — picture only, the cell shows the label separately.
    /// `.standard` (practice card, ~120pt) — picture + a one-line "do this" caption.
    /// `.full` (detail screen, ~180pt) — picture + a leader line naming the active part + caption.
    enum Style { case compact, standard, full }
    var style: Style = .standard

    /// When true (and Reduce Motion is off), the highlight and motion glyph gently pulse.
    var animated: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The action a parent should make, derived from the phoneme's own plain-language `manner`
    /// and `kind` — no extra data needed. Drives the motion glyph.
    private enum Gesture { case pop, stream, nasal, glide, lateral, vowel }
    private var gesture: Gesture {
        if phoneme.kind == .vowel { return .vowel }
        let m = phoneme.manner.lowercased()
        if m.contains("nose") { return .nasal }
        if m.contains("stream") { return .stream }
        if m.contains("glide") { return .glide }
        if m.contains("round the tongue") { return .lateral }
        if m.contains("pop") || m.contains("tap") { return .pop }
        return .vowel
    }

    private var isVoiced: Bool { phoneme.voicing == .voiced }

    /// A plain-language name for the highlighted part.
    private var partName: String {
        switch phoneme.articulator {
        case .lips:       return "lips"
        case .tongueTip:  return "tongue tip"
        case .tongueBack: return "back of tongue"
        case .open:       return "open mouth"
        case .rounded:    return "rounded lips"
        case .teethOnLip: return "top teeth on lip"
        }
    }

    /// A short placement caption — concise enough to sit under a small diagram. The fuller
    /// step-by-step guidance lives in the detail screen's "Show your child" card.
    private var caption: String { phoneme.place }

    var body: some View {
        VStack(spacing: Theme.sp1) {
            drawing
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if style != .compact {
                Text(caption)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.brandInk)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Theme.sp2)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Side view of the mouth, \(partName) highlighted. \(caption)")
    }

    @ViewBuilder private var drawing: some View {
        if animated && !reduceMotion {
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                // Smooth 0.55 … 1.0 breathing pulse, ~one cycle per ~1.4s.
                let pulse = 0.55 + 0.45 * (sin(t * 4.5) * 0.5 + 0.5)
                canvas(pulse: pulse)
            }
        } else {
            canvas(pulse: 1)
        }
    }

    private func canvas(pulse: Double) -> some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let lineW = max(2, w * 0.014)
            let highlight = Theme.brand.opacity(0.55 + 0.45 * pulse)   // active part fill
            let highlightLine = Theme.brand
            let neutral = Theme.label3.opacity(0.7)
            let faint = Theme.label3.opacity(0.35)
            let glyphColor = Theme.accent.opacity(0.6 + 0.4 * pulse)

            // Map the 0…1 design space into a band inset from the left so the front of the
            // mouth and the air-flow glyphs have room and never clip the frame edge.
            func p(_ fx: Double, _ fy: Double) -> CGPoint {
                CGPoint(x: w * (0.06 + fx * 0.90), y: h * fy)
            }
            func stroke(_ path: Path, _ color: Color, _ width: Double, dash: [CGFloat] = []) {
                ctx.stroke(path, with: .color(color),
                           style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
            }
            func fill(_ path: Path, _ color: Color) { ctx.fill(path, with: .color(color)) }

            let art = phoneme.articulator
            let lipsActive = art == .lips || art == .rounded
            let tongueActive = art == .tongueTip || art == .tongueBack

            // ── Head silhouette (left-facing): a faint backdrop so it reads as a face in profile.
            var head = Path()
            head.move(to: p(0.46, 0.10))
            head.addQuadCurve(to: p(0.30, 0.20), control: p(0.36, 0.12))   // brow
            head.addQuadCurve(to: p(0.13, 0.31), control: p(0.18, 0.24))   // nose bridge → tip (juts left)
            head.addQuadCurve(to: p(0.23, 0.39), control: p(0.16, 0.37))   // under the nose
            head.addLine(to: p(0.16, 0.45))                                 // up to the top lip
            head.addQuadCurve(to: p(0.18, 0.60), control: p(0.10, 0.53))   // lips (front)
            head.addQuadCurve(to: p(0.27, 0.71), control: p(0.18, 0.69))   // chin (juts low-left)
            head.addQuadCurve(to: p(0.46, 0.82), control: p(0.34, 0.82))   // jaw line
            head.addQuadCurve(to: p(0.74, 0.62), control: p(0.72, 0.80))   // under jaw → back of neck
            head.addQuadCurve(to: p(0.78, 0.34), control: p(0.84, 0.46))   // back of head
            head.addQuadCurve(to: p(0.46, 0.10), control: p(0.66, 0.14))   // crown → forehead
            head.closeSubpath()
            fill(head, Theme.brand.opacity(0.06))
            stroke(head, Theme.hairline, lineW)

            // ── Hard palate / roof of the mouth: the curved top of the oral cavity.
            var palate = Path()
            palate.move(to: p(0.30, 0.50))                                  // behind the upper teeth (alveolar ridge)
            palate.addQuadCurve(to: p(0.48, 0.43), control: p(0.38, 0.41))  // dome of the hard palate
            palate.addQuadCurve(to: p(0.62, 0.52), control: p(0.60, 0.45))  // soft palate / velum at the back
            let palateActive = art == .tongueBack
            stroke(palate, palateActive ? highlightLine : neutral, lineW * (palateActive ? 1.4 : 1))

            // ── Nasal passage: a faint channel above the palate (where the hum escapes for m/n/ng).
            var nasal = Path()
            nasal.move(to: p(0.21, 0.37))
            nasal.addQuadCurve(to: p(0.58, 0.40), control: p(0.40, 0.33))
            stroke(nasal, faint, max(1, lineW * 0.7), dash: [w * 0.012, w * 0.012])

            // ── Throat / pharynx: a vertical channel at the back (anchor for the voiced buzz).
            var throat = Path()
            throat.move(to: p(0.62, 0.52))
            throat.addQuadCurve(to: p(0.60, 0.78), control: p(0.66, 0.66))
            stroke(throat, faint, lineW)

            // ── Teeth: short ridges at the front, a fixed reference between lips and tongue.
            let teethActive = art == .teethOnLip
            let teethColor = teethActive ? highlightLine : neutral
            var upperTeeth = Path()                                         // hang down from the top lip
            upperTeeth.move(to: p(0.265, 0.47)); upperTeeth.addLine(to: p(0.265, 0.525))
            var lowerTeeth = Path()                                         // stand up from the bottom lip
            lowerTeeth.move(to: p(0.265, 0.585)); lowerTeeth.addLine(to: p(0.265, 0.54))
            stroke(upperTeeth, teethColor, lineW * (teethActive ? 2.2 : 1.4))
            stroke(lowerTeeth, art == .teethOnLip ? neutral : neutral, lineW * 1.4)

            // ── Tongue: a filled mass whose surface rises where the sound is made.
            var tongue = Path()
            tongue.move(to: p(0.28, 0.62))
            switch art {
            case .tongueTip:                                                // tip lifts to the ridge
                tongue.addQuadCurve(to: p(0.305, 0.515), control: p(0.27, 0.55))
                tongue.addQuadCurve(to: p(0.46, 0.63), control: p(0.40, 0.66))
                tongue.addQuadCurve(to: p(0.60, 0.58), control: p(0.56, 0.57))
            case .tongueBack:                                               // back humps to the velum
                tongue.addQuadCurve(to: p(0.40, 0.63), control: p(0.33, 0.61))
                tongue.addQuadCurve(to: p(0.575, 0.50), control: p(0.50, 0.50))
                tongue.addQuadCurve(to: p(0.61, 0.55), control: p(0.60, 0.51))
            default:                                                        // relaxed / low for lips & vowels
                tongue.addQuadCurve(to: p(0.44, 0.61), control: p(0.34, 0.58))
                tongue.addQuadCurve(to: p(0.60, 0.59), control: p(0.54, 0.58))
            }
            tongue.addQuadCurve(to: p(0.58, 0.74), control: p(0.62, 0.70))  // back of the tongue down to the floor
            tongue.addLine(to: p(0.31, 0.74))
            tongue.addQuadCurve(to: p(0.28, 0.62), control: p(0.27, 0.70))  // floor back to the tip
            tongue.closeSubpath()
            fill(tongue, tongueActive ? highlight : neutral.opacity(0.5))
            stroke(tongue, tongueActive ? highlightLine : neutral, lineW)

            // ── Lips at the front (left). Closed, rounded, or open depending on the sound.
            let lipColor = lipsActive ? highlightLine : neutral
            if art == .rounded {
                var o = Path()                                              // a small forward "O"
                o.addEllipse(in: CGRect(x: w * 0.085, y: h * 0.475, width: w * 0.085, height: h * 0.11))
                stroke(o, lipColor, lineW * 1.8)
            } else if art == .open {
                var gap = Path()                                            // an open gap between the lips
                gap.addEllipse(in: CGRect(x: w * 0.095, y: h * 0.45, width: w * 0.085, height: h * 0.16))
                fill(gap, highlight.opacity(0.5))
                stroke(gap, highlightLine, lineW * 1.4)
            } else {
                var upper = Path()
                upper.move(to: p(0.10, 0.50))
                upper.addQuadCurve(to: p(0.22, 0.49), control: p(0.16, 0.455))
                var lower = Path()
                lower.move(to: p(0.10, 0.555))
                lower.addQuadCurve(to: p(0.22, 0.565), control: p(0.16, 0.60))
                // For f/v the lower lip is part of the action — tint it with the teeth.
                stroke(upper, lipColor, lineW * 1.8)
                stroke(lower, art == .teethOnLip ? highlightLine : lipColor, lineW * 1.8)
            }

            // ── Motion glyph: the *action*. Drawn in the accent colour, on top of the cavity.
            drawGlyph(ctx: ctx, p: p, w: w, h: h, lineW: lineW, color: glyphColor)
            if isVoiced { drawBuzz(ctx: ctx, p: p, w: w, h: h, lineW: lineW, color: glyphColor) }

            // ── A dot marking the exact spot the sound is made.
            let anchor = p(anchorPoint.x, anchorPoint.y)
            var dot = Path()
            dot.addEllipse(in: CGRect(x: anchor.x - w * 0.013, y: anchor.y - w * 0.013,
                                      width: w * 0.026, height: w * 0.026))
            fill(dot, highlightLine)

            // ── Orientation title (standard & full only — too small to help in the grid).
            if style != .compact {
                let title = ctx.resolve(
                    Text("Side view of the mouth").font(.caption2.weight(.medium)).foregroundStyle(Theme.label3)
                )
                ctx.draw(title, at: p(0.5, 0.05), anchor: .center)
            }

            // ── Leader line + part name (full only): connects the word to the spot it names.
            if style == .full {
                let labelPt = p(0.5, 0.93)
                var leader = Path()
                leader.move(to: CGPoint(x: anchor.x, y: anchor.y + w * 0.02))
                leader.addLine(to: CGPoint(x: anchor.x, y: h * 0.88))
                leader.addLine(to: CGPoint(x: labelPt.x, y: h * 0.88))
                stroke(leader, faint, max(1, lineW * 0.6))
                let word = ctx.resolve(
                    Text(partName).font(.caption.weight(.semibold)).foregroundStyle(Theme.brandInk)
                )
                ctx.draw(word, at: labelPt, anchor: .center)
            }
        }
    }

    /// Where the sound is made — the dot, and the target of the leader line.
    private var anchorPoint: CGPoint {
        switch phoneme.articulator {
        case .lips, .rounded, .open: return CGPoint(x: 0.13, y: 0.53)
        case .teethOnLip:            return CGPoint(x: 0.24, y: 0.55)
        case .tongueTip:             return CGPoint(x: 0.30, y: 0.51)
        case .tongueBack:            return CGPoint(x: 0.57, y: 0.50)
        }
    }

    /// Draws the per-gesture motion cue.
    private func drawGlyph(ctx: GraphicsContext, p: (Double, Double) -> CGPoint,
                           w: Double, h: Double, lineW: Double, color: Color) {
        func stroke(_ path: Path, _ width: Double, dash: [CGFloat] = []) {
            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
        }
        // A small arrowhead pointing in `angle` (radians) at point `pt`.
        func arrowhead(at pt: CGPoint, angle: Double, size: Double) {
            var a = Path()
            for s in [2.6, -2.6] {
                a.move(to: pt)
                a.addLine(to: CGPoint(x: pt.x + cos(angle + s) * size, y: pt.y + sin(angle + s) * size))
            }
            stroke(a, lineW * 1.2)
        }

        switch gesture {
        case .pop:
            // A burst of short rays just outside the lips — the puff of air.
            let c = p(0.06, 0.53)
            var rays = Path()
            for k in 0..<6 {
                let ang = Double.pi * (0.62 + Double(k) * 0.25)
                rays.move(to: CGPoint(x: c.x + cos(ang) * w * 0.02, y: c.y + sin(ang) * w * 0.02))
                rays.addLine(to: CGPoint(x: c.x + cos(ang) * w * 0.06, y: c.y + sin(ang) * w * 0.06))
            }
            stroke(rays, lineW * 1.3)

        case .stream:
            // A long wavy arrow flowing forward out of the mouth.
            var wave = Path()
            wave.move(to: p(0.16, 0.53))
            wave.addQuadCurve(to: p(0.10, 0.50), control: p(0.13, 0.485))
            wave.addQuadCurve(to: p(0.04, 0.55), control: p(0.07, 0.575))
            stroke(wave, lineW * 1.3)
            arrowhead(at: p(0.04, 0.55), angle: .pi * 0.85, size: w * 0.035)

        case .nasal:
            // An arrow rising at the back, then forward out of the nose.
            var path = Path()
            path.move(to: p(0.56, 0.55))
            path.addQuadCurve(to: p(0.40, 0.34), control: p(0.50, 0.40))
            path.addQuadCurve(to: p(0.16, 0.32), control: p(0.28, 0.30))
            stroke(path, lineW * 1.3)
            arrowhead(at: p(0.16, 0.32), angle: .pi * 0.95, size: w * 0.035)

        case .glide:
            // A forward sweep — the sound moves into the next.
            var path = Path()
            path.move(to: p(0.18, 0.53))
            path.addQuadCurve(to: p(0.04, 0.50), control: p(0.10, 0.49))
            stroke(path, lineW * 1.3)
            arrowhead(at: p(0.04, 0.50), angle: .pi * 0.9, size: w * 0.04)

        case .lateral:
            // Air flowing around the sides of the tongue, then out.
            var path = Path()
            path.move(to: p(0.40, 0.60))
            path.addQuadCurve(to: p(0.16, 0.62), control: p(0.28, 0.66))
            path.addQuadCurve(to: p(0.05, 0.56), control: p(0.09, 0.60))
            stroke(path, lineW * 1.3)
            arrowhead(at: p(0.05, 0.56), angle: .pi * 0.8, size: w * 0.035)

        case .vowel:
            // Sustained voice radiating from the open mouth.
            for r in [0.05, 0.085, 0.12] {
                var arc = Path()
                let c = p(0.13, 0.53)
                arc.addArc(center: c, radius: w * r,
                           startAngle: .degrees(120), endAngle: .degrees(240), clockwise: false)
                stroke(arc, lineW * 1.1)
            }
        }
    }

    /// Concentric arcs at the throat — "voice on, it buzzes".
    private func drawBuzz(ctx: GraphicsContext, p: (Double, Double) -> CGPoint,
                          w: Double, h: Double, lineW: Double, color: Color) {
        let c = p(0.63, 0.70)
        for r in [0.025, 0.05] {
            var arc = Path()
            arc.addArc(center: c, radius: w * r,
                       startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
            ctx.stroke(arc, with: .color(color),
                       style: StrokeStyle(lineWidth: lineW, lineCap: .round))
        }
    }
}
