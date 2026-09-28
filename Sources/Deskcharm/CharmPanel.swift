import AppKit
import SwiftUI

final class CharmPanel: NSPanel {
    let rope: Rope

    private let settings: Settings
    private var monitors: [Any] = []
    private var lastMouseX: CGFloat = .nan

    private let feelRadius: CGFloat = 190

    init(settings: Settings) {
        self.settings = settings
        let screen = NSScreen.main
        let bounds = screen?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let size = CGSize(width: bounds.width, height: 560)

        let rope = Rope(
            anchor: CGPoint(x: bounds.width * settings.position, y: 0),
            length: settings.cordLength
        )
        self.rope = rope

        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .statusBar
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        hidesOnDeactivate = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        let host = NSHostingView(rootView: CharmView(rope: rope, settings: settings))
        host.frame = NSRect(origin: .zero, size: size)
        contentView = host

        setFrameOrigin(NSPoint(x: bounds.minX, y: bounds.maxY - size.height))
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func applyPosition() {
        let width = NSScreen.main?.frame.width ?? frame.width
        let margin = settings.beadSize
        let x = min(max(width * settings.position, margin), width - margin)
        rope.reanchor(to: CGPoint(x: x, y: 0))
    }

    func startTracking() {
        let global = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] _ in
            MainActor.assumeIsolated { self?.followCursor() }
        }
        let local = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            MainActor.assumeIsolated { self?.followCursor() }
            return event
        }
        monitors = [global, local].compactMap { $0 }
    }

    private func followCursor() {
        let mouse = NSEvent.mouseLocation
        let radius = settings.beadSize / 2
        let tip = rope.beadCenter(radius: radius)
        let tipOnScreen = CGPoint(x: frame.minX + tip.x, y: frame.maxY - tip.y)

        let dx = mouse.x - tipOnScreen.x
        let dy = mouse.y - tipOnScreen.y
        let distance = sqrt(dx * dx + dy * dy)

        ignoresMouseEvents = distance > radius + 14

        defer { lastMouseX = mouse.x }
        guard distance < feelRadius, !lastMouseX.isNaN else { return }

        let travel = mouse.x - lastMouseX
        let falloff = 1 - (distance / feelRadius)
        rope.nudge(by: travel * falloff * falloff * settings.sensitivity)
    }
}
