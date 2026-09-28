import AppKit
import SwiftUI

@MainActor
final class Settings: ObservableObject {
    static let sizes: [(name: String, value: CGFloat)] = [
        ("Small", 72), ("Medium", 96), ("Large", 128),
    ]

    static let lengths: [(name: String, value: CGFloat)] = [
        ("Short", 130), ("Medium", 212), ("Long", 320),
    ]

    static let sensitivities: [(name: String, value: CGFloat)] = [
        ("Calm", 0.22), ("Normal", 0.5), ("Lively", 1.0),
    ]

    static let swings: [(name: String, value: CGFloat)] = [
        ("Off", 0), ("Gentle", 0.009), ("Breezy", 0.022),
    ]

    static let positions: [(name: String, value: CGFloat)] = [
        ("Far left", 0.05), ("Left", 0.20), ("Center", 0.50),
        ("Right", 0.80), ("Far right", 0.94),
    ]

    @Published var beadSize: CGFloat { didSet { store(beadSize, at: .beadSize) } }
    @Published var cordLength: CGFloat { didSet { store(cordLength, at: .cordLength) } }
    @Published var sensitivity: CGFloat { didSet { store(sensitivity, at: .sensitivity) } }
    @Published var swing: CGFloat { didSet { store(swing, at: .swing) } }

    @Published var position: CGFloat { didSet { store(position, at: .position) } }

    @Published var charm: Charm {
        didSet { UserDefaults.standard.set(charm.rawValue, forKey: Key.charm.rawValue) }
    }

    @Published private(set) var photo: NSImage?

    private static let photoFile = URL.applicationSupportDirectory
        .appending(path: "Deskcharm", directoryHint: .isDirectory)
        .appending(path: "photo")

    func setPhoto(from url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let image = NSImage(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try FileManager.default.createDirectory(
            at: Settings.photoFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: Settings.photoFile, options: .atomic)
        photo = image
    }

    init() {
        let savedPhoto = (try? Data(contentsOf: Settings.photoFile)).flatMap(NSImage.init(data:))
        photo = savedPhoto

        beadSize = Settings.read(.beadSize, fallback: 96)
        cordLength = Settings.read(.cordLength, fallback: 212)
        sensitivity = Settings.read(.sensitivity, fallback: 0.5)
        swing = Settings.read(.swing, fallback: 0)
        position = Settings.read(.position, fallback: 0.80)

        let stored = UserDefaults.standard.string(forKey: Key.charm.rawValue)
        let restored = stored.flatMap(Charm.init(rawValue:)) ?? .nazar
        charm = restored == .photo && savedPhoto == nil ? .nazar : restored
    }

    private enum Key: String {
        case beadSize = "deskcharm.beadSize"
        case cordLength = "deskcharm.cordLength"
        case sensitivity = "deskcharm.sensitivity"
        case swing = "deskcharm.swing"
        case position = "deskcharm.position"
        case charm = "deskcharm.charm"
    }

    private static func read(_ key: Key, fallback: CGFloat) -> CGFloat {
        guard let stored = UserDefaults.standard.object(forKey: key.rawValue) as? Double else {
            return fallback
        }
        return CGFloat(stored)
    }

    private func store(_ value: CGFloat, at key: Key) {
        UserDefaults.standard.set(Double(value), forKey: key.rawValue)
    }
}
