import SwiftUI
import UIKit

// MARK: - Color helpers

extension Color {
    /// A color that resolves differently in light vs dark. Every Theme token is built
    /// from these so dark mode is automatic.
    init(light: Color, dark: Color) {
        self = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Build a color from a `#RRGGBB` or `#RRGGBBAA` hex string.
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        switch s.count {
        case 8:
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        default:
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Theme tokens (Bright Sky · light + Deep Sky · dark)

/// The single source of truth for color, shape, and metrics. Rule: views read these
/// tokens — they never hard-code a hex — so both light and dark follow the system scheme.
enum Theme {

    // ---- Brand (a calm, encouraging blue/teal — speech & communication) -----
    static let brand     = Color(light: Color(hex: "#3B82C4"), dark: Color(hex: "#6FB0E8"))
    static let brandInk  = Color(light: Color(hex: "#2C649A"), dark: Color(hex: "#9CCBF2"))
    static let accent    = Color(light: Color(hex: "#F2A03D"), dark: Color(hex: "#F6B968"))
    static let accentInk = Color(light: Color(hex: "#D27F1E"), dark: Color(hex: "#F9CB8E"))

    // ---- Surfaces & neutrals -----------------------------------------------
    static let bg        = Color(light: Color(hex: "#F7FBFF"), dark: Color(hex: "#10171F"))
    static let bgGrouped = Color(light: Color(hex: "#EDF4FB"), dark: Color(hex: "#141C26"))
    static let card      = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1B2530"))
    static let fillQuat  = Color(light: Color(hex: "#1B3A5A14"), dark: Color(hex: "#FFFFFF14"))
    static let hairline  = Color(light: Color(hex: "#1B3A5A24"), dark: Color(hex: "#FFFFFF1F"))

    // ---- Text --------------------------------------------------------------
    static let label   = Color(light: Color(hex: "#1E2A36"), dark: Color(hex: "#E8EEF4"))
    static let label2  = Color(light: Color(hex: "#5A6B7B"), dark: Color(hex: "#9DAFBF"))
    static let label3  = Color(light: Color(hex: "#92A2B2"), dark: Color(hex: "#62748A"))
    static let onColor = Color.white

    // ---- Semantic colors (by meaning, never decoration) --------------------
    /// Practice ratings map to these three.
    static let correct = Color(light: Color(hex: "#3FA66A"), dark: Color(hex: "#5FC489"))
    static let approx  = Color(light: Color(hex: "#E9A23B"), dark: Color(hex: "#F0BA62"))
    static let tryAgain = Color(light: Color(hex: "#6C8094"), dark: Color(hex: "#8AA0B4"))

    static let green  = correct
    static let blue   = brand
    static let orange = Color(light: Color(hex: "#E0913F"), dark: Color(hex: "#E8A85C"))
    static let teal   = Color(light: Color(hex: "#3BA8A0"), dark: Color(hex: "#5FC6BE"))
    static let pink   = Color(light: Color(hex: "#D98BA0"), dark: Color(hex: "#E6A3B5"))
    static let purple = Color(light: Color(hex: "#8B7FD0"), dark: Color(hex: "#A99EE6"))
    static let red    = Color(light: Color(hex: "#D5694E"), dark: Color(hex: "#E2856A"))

    static func tint(_ color: Color, _ level: Double = 0.16) -> Color { color.opacity(level) }

    // ---- Responsive layout helpers -----------------------------------------
    static func adaptiveColumns(min: CGFloat, max: CGFloat = .infinity,
                                spacing: CGFloat = Theme.sp3) -> [GridItem] {
        [GridItem(.adaptive(minimum: min, maximum: max), spacing: spacing)]
    }

    static let contentMaxWidth: CGFloat = 640
    static let playMaxWidth: CGFloat = 900

    // ---- Shape & metrics ---------------------------------------------------
    static let corner: CGFloat   = 24
    static let cornerSm: CGFloat = 16
    static let cornerXs: CGFloat = 12

    static let tapBig: CGFloat    = 64
    static let tapMin: CGFloat    = 44
    static let btnHeight: CGFloat = 52
    static let bigButton: CGFloat = 120   // chunky kid-facing buttons

    // ---- Spacing rhythm ----------------------------------------------------
    static let sp1: CGFloat = 4
    static let sp2: CGFloat = 8
    static let sp3: CGFloat = 12
    static let sp4: CGFloat = 16
    static let sp5: CGFloat = 20
    static let sp6: CGFloat = 24

    static let shadowColor = Color(light: Color(hex: "#1B3A5A1A"), dark: .black.opacity(0.4))
}
