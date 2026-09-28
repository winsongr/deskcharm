import AppKit
import ServiceManagement
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = Settings()
    private var panel: CharmPanel?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let panel = CharmPanel(settings: settings)
        panel.orderFrontRegardless()
        self.panel = panel

        let item = NSStatusBar.system.statusItem(withLength: 20)
        item.menu = buildMenu()
        statusItem = item
        applyGlyph()

        panel.rope.breeze = settings.swing
        panel.rope.start()
        panel.startTracking()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let charms = NSMenuItem(title: "Charm", action: nil, keyEquivalent: "")
        let charmMenu = NSMenu()
        for charm in Charm.allCases {
            let item = NSMenuItem(title: "\(charm.glyph)  \(charm.name)", action: #selector(pickCharm), keyEquivalent: "")
            item.target = self
            item.representedObject = charm.rawValue
            item.state = charm == settings.charm ? .on : .off
            charmMenu.addItem(item)
        }
        charms.submenu = charmMenu
        menu.addItem(charms)
        menu.addItem(.separator())

        menu.addItem(submenu("Size", options: Settings.sizes, current: settings.beadSize, action: #selector(pickSize)))
        menu.addItem(submenu("Length", options: Settings.lengths, current: settings.cordLength, action: #selector(pickLength)))
        menu.addItem(submenu("Sensitivity", options: Settings.sensitivities, current: settings.sensitivity, action: #selector(pickSensitivity)))
        menu.addItem(submenu("Swing", options: Settings.swings, current: settings.swing, action: #selector(pickSwing)))
        menu.addItem(submenu("Position", options: Settings.positions, current: settings.position, action: #selector(pickPosition)))

        menu.addItem(.separator())
        let login = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)

        menu.addItem(.separator())
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let info = NSMenuItem(title: "Deskcharm \(version) (\(build))", action: nil, keyEquivalent: "")
            info.isEnabled = false
            menu.addItem(info)
        }
        menu.addItem(withTitle: "Quit Deskcharm", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    private func submenu(
        _ title: String,
        options: [(name: String, value: CGFloat)],
        current: CGFloat,
        action: Selector
    ) -> NSMenuItem {
        let parent = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let child = NSMenu()

        for (index, option) in options.enumerated() {
            let item = NSMenuItem(title: option.name, action: action, keyEquivalent: "")
            item.target = self
            item.tag = index
            item.state = abs(option.value - current) < 0.001 ? .on : .off
            child.addItem(item)
        }

        parent.submenu = child
        return parent
    }

    @objc private func pickSize(_ sender: NSMenuItem) {
        settings.beadSize = Settings.sizes[sender.tag].value
        refresh()
    }

    @objc private func pickLength(_ sender: NSMenuItem) {
        settings.cordLength = Settings.lengths[sender.tag].value
        panel?.rope.resize(length: settings.cordLength)
        refresh()
    }

    @objc private func pickSensitivity(_ sender: NSMenuItem) {
        settings.sensitivity = Settings.sensitivities[sender.tag].value
        refresh()
    }

    @objc private func pickSwing(_ sender: NSMenuItem) {
        settings.swing = Settings.swings[sender.tag].value
        panel?.rope.breeze = settings.swing
        refresh()
    }

    @objc private func pickPosition(_ sender: NSMenuItem) {
        settings.position = Settings.positions[sender.tag].value
        panel?.applyPosition()
        refresh()
    }

    @objc private func pickCharm(_ sender: NSMenuItem) {
        guard
            let raw = sender.representedObject as? String,
            let charm = Charm(rawValue: raw)
        else { return }

        if charm == .photo {
            guard choosePhoto() || settings.photo != nil else { return }
        }

        settings.charm = charm
        applyGlyph()
        refresh()
    }

    private func choosePhoto() -> Bool {
        let picker = NSOpenPanel()
        picker.title = "Choose a photo for your charm"
        picker.allowedContentTypes = [.image]
        picker.allowsMultipleSelection = false
        picker.canChooseDirectories = false

        NSApp.activate()
        guard picker.runModal() == .OK, let url = picker.url else { return false }

        do {
            try settings.setPhoto(from: url)
            return true
        } catch {
            NSAlert(error: error).runModal()
            return false
        }
    }

    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
        if service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
        refresh()
    }

    private func applyGlyph() {
        guard let button = statusItem?.button else { return }
        button.imagePosition = .noImage
        button.attributedTitle = NSAttributedString(
            string: settings.charm.glyph,
            attributes: [
                .font: NSFont.systemFont(ofSize: 12),
                .baselineOffset: 0.5,
            ]
        )
    }

    private func refresh() {
        statusItem?.menu = buildMenu()
    }
}
