import SwiftUI

enum Charm: String, CaseIterable {
    case nazar
    case clover
    case sparkles

    var name: String {
        switch self {
        case .nazar: "Nazar"
        case .clover: "Clover"
        case .sparkles: "Sparkles"
        }
    }

    var glyph: String {
        switch self {
        case .nazar: "🧿"
        case .clover: "🍀"
        case .sparkles: "✨"
        }
    }
}
