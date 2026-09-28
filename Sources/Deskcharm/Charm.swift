import SwiftUI

enum Charm: String, CaseIterable {
    case nazar
    case clover
    case sparkles
    case photo

    var name: String {
        switch self {
        case .nazar: "Nazar"
        case .clover: "Clover"
        case .sparkles: "Sparkles"
        case .photo: "Photo…"
        }
    }

    var glyph: String {
        switch self {
        case .nazar: "🧿"
        case .clover: "🍀"
        case .sparkles: "✨"
        case .photo: "📷"
        }
    }
}
