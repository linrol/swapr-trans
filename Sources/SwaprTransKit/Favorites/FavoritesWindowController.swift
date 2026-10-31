import AppKit
import SwiftUI

@MainActor
public final class FavoritesWindowController: NSObject, NSWindowDelegate {
    public static let shared = FavoritesWindowController()

    private var window: NSWindow?

    private override init() {
        super.init()
    }

    public func show() {
        if window == nil {
            let contentView = FavoritesListView()
            let hostingController = NSHostingController(rootView: contentView)

            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 560),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            w.title = "Saved Translations"
            w.minSize = NSSize(width: 380, height: 360)
            w.center()
            w.contentViewController = hostingController
            w.isReleasedWhenClosed = false
            w.delegate = self
            w.titleVisibility = .visible
            w.titlebarAppearsTransparent = false

            self.window = w
        }

        guard let w = window else { return }

        // Bring to front
        w.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    public func close() {
        window?.close()
    }

    // MARK: - NSWindowDelegate

    public func windowWillClose(_ notification: Notification) {
        // Stop any speech when window is closed
        FavoritesManager.shared.toggleSpeech(for: "")
    }
}

