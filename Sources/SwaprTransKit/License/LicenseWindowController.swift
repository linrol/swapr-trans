import AppKit
import SwiftUI

@MainActor
public final class LicenseWindowController: NSObject, NSWindowDelegate {
    public static let shared = LicenseWindowController()

    private var window: NSWindow?

    private override init() {
        super.init()
    }

    public func show() {
        if window == nil {
            let contentView = LicenseActivationView()
            let hostingController = NSHostingController(rootView: contentView)

            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 440, height: 490),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            w.title = "SwaprTrans Pro"
            w.center()
            w.contentViewController = hostingController
            w.isReleasedWhenClosed = false
            w.delegate = self
            w.titleVisibility = .visible

            self.window = w
        }

        guard let w = window else { return }

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
}

