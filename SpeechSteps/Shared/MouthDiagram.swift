import SwiftUI

/// An original, generated mouth-position diagram. Drawn entirely with SwiftUI shapes from
/// a phoneme's `articulator` — so it ships no licensed cue artwork, scales crisply, and
/// adapts to light/dark automatically. A simple side-on face: lips, teeth, tongue, with the
/// active articulator highlighted to show a parent *where* the sound is made.
struct MouthDiagram: View {
    let articulator: Phoneme.Articulator

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let highlight = Theme.brand
            let neutral = Theme.label3
            let lineW = max(2, w * 0.018)

            // Face outline (a soft profile facing left).
            var face = Path()
            face.addArc(center: CGPoint(x: w * 0.52, y: h * 0.5),
                        radius: min(w, h) * 0.42, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            ctx.stroke(face, with: .color(Theme.hairline), lineWidth: lineW)

            // Upper and lower lips (left side of the face).
            let lipsActive = articulator == .lips || articulator == .rounded
            let lipColor = lipsActive ? highlight : neutral
            let lipX = w * 0.16
            if articulator == .rounded {
                // Rounded lips: a small open circle.
                var o = Path()
                o.addEllipse(in: CGRect(x: lipX - w * 0.02, y: h * 0.42, width: w * 0.12, height: h * 0.16))
                ctx.stroke(o, with: .color(lipColor), lineWidth: lineW * 1.4)
            } else {
                var upper = Path()
                upper.move(to: CGPoint(x: lipX, y: h * 0.44))
                upper.addQuadCurve(to: CGPoint(x: lipX + w * 0.12, y: h * 0.46),
                                   control: CGPoint(x: lipX + w * 0.06, y: h * 0.40))
                var lower = Path()
                lower.move(to: CGPoint(x: lipX, y: h * 0.56))
                lower.addQuadCurve(to: CGPoint(x: lipX + w * 0.12, y: h * 0.54),
                                   control: CGPoint(x: lipX + w * 0.06, y: h * 0.60))
                ctx.stroke(upper, with: .color(lipColor), lineWidth: lineW * 1.4)
                ctx.stroke(lower, with: .color(lipColor), lineWidth: lineW * 1.4)
            }

            // Tongue — position depends on the articulator.
            let tongueActive = articulator == .tongueTip || articulator == .tongueBack
            let tongueColor = tongueActive ? highlight : neutral.opacity(0.7)
            var tongue = Path()
            switch articulator {
            case .tongueTip:
                tongue.move(to: CGPoint(x: w * 0.22, y: h * 0.56))
                tongue.addQuadCurve(to: CGPoint(x: w * 0.40, y: h * 0.46),
                                    control: CGPoint(x: w * 0.30, y: h * 0.40))
            case .tongueBack:
                tongue.move(to: CGPoint(x: w * 0.22, y: h * 0.56))
                tongue.addQuadCurve(to: CGPoint(x: w * 0.48, y: h * 0.44),
                                    control: CGPoint(x: w * 0.46, y: h * 0.56))
            default:
                tongue.move(to: CGPoint(x: w * 0.22, y: h * 0.56))
                tongue.addQuadCurve(to: CGPoint(x: w * 0.42, y: h * 0.54),
                                    control: CGPoint(x: w * 0.32, y: h * 0.52))
            }
            ctx.stroke(tongue, with: .color(tongueColor), lineWidth: lineW * 1.6)

            // Open-mouth marker for vowels / h.
            if articulator == .open {
                var open = Path()
                open.addEllipse(in: CGRect(x: lipX - w * 0.01, y: h * 0.40, width: w * 0.14, height: h * 0.22))
                ctx.stroke(open, with: .color(highlight), lineWidth: lineW * 1.4)
            }
        }
        .accessibilityHidden(true)
    }
}
