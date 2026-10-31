import Foundation
import Combine
import AppKit
import ApplicationServices

public enum SwaprLogLevel: String, Codable {
    case info
    case success
    case warning
    case error
}

@MainActor
public final class SwaprTransConfig: ObservableObject {
    public static let shared = SwaprTransConfig()

    private let defaults = UserDefaults.standard
    private let keyEnabled = "swapr_trans_enabled"
    private let keyProvider = "swapr_trans_provider"
    private let keyShortcut = "swapr_trans_shortcut"
    private let keyDismissSeconds = "swapr_trans_dismiss_seconds"
    private let keyHudOpacity = "swapr_trans_hud_opacity"
    private let keyFavoritesEnabled = "swapr_trans_favorites_enabled"

    private var isInitialized = false

    @Published public var isEnabled: Bool = false {
        didSet {
            guard isInitialized else { return }
            defaults.set(isEnabled, forKey: keyEnabled)
            handleStateChanged()
        }
    }

    @Published public var provider: TranslationProvider = .apple {
        didSet {
            guard isInitialized else { return }
            defaults.set(provider.rawValue, forKey: keyProvider)
            log("Translation provider changed to: \(provider.displayName)", level: .info)
        }
    }

    @Published public var shortcut: TranslationShortcut = .defaultShortcut {
        didSet {
            guard isInitialized else { return }
            if let data = try? JSONEncoder().encode(shortcut) {
                defaults.set(data, forKey: keyShortcut)
            }
            if isEnabled {
                TranslateMonitor.shared.restartMonitoring(with: shortcut)
            }
            log("Translation shortcut updated to: \(shortcut.label)", level: .info)
        }
    }

    @Published public var autoDismissSeconds: Int = 0 {
        didSet {
            guard isInitialized else { return }
            defaults.set(autoDismissSeconds, forKey: keyDismissSeconds)
        }
    }

    @Published public var hudOpacity: Double = 0.95 {
        didSet {
            guard isInitialized else { return }
            defaults.set(hudOpacity, forKey: keyHudOpacity)
            TranslationHudController.shared.updateOpacity(hudOpacity)
        }
    }

    @Published public var isFavoritesEnabled: Bool = false {
        didSet {
            guard isInitialized else { return }
            defaults.set(isFavoritesEnabled, forKey: keyFavoritesEnabled)
        }
    }

    @Published public var hasAccessibilityPermission: Bool = false

    /// Bundle identifiers of apps where shortcut should NOT trigger
    public var ignoredAppBundleIdentifiers: Set<String> = []

    /// App names substring that should NOT trigger
    public var ignoredAppNameKeywords: Set<String> = ["swaprtrans", "swapr trans"]

    /// External logging callback hook
    public var logHandler: ((String, SwaprLogLevel) -> Void)?

    private init() {
        self.isEnabled = defaults.bool(forKey: keyEnabled)

        if let savedProviderRaw = defaults.string(forKey: keyProvider),
           let p = TranslationProvider(rawValue: savedProviderRaw) {
            self.provider = p
        }

        if let shortcutData = defaults.data(forKey: keyShortcut),
           let sc = try? JSONDecoder().decode(TranslationShortcut.self, from: shortcutData) {
            if let matched = TranslationShortcut.presets.first(where: { $0.keyCode == sc.keyCode && $0.modifiers == sc.modifiers }) {
                self.shortcut = matched
            } else {
                self.shortcut = sc
            }
        }

        if defaults.object(forKey: keyDismissSeconds) != nil {
            self.autoDismissSeconds = defaults.integer(forKey: keyDismissSeconds)
        } else {
            self.autoDismissSeconds = 0
            defaults.set(0, forKey: keyDismissSeconds)
        }

        if defaults.object(forKey: keyHudOpacity) != nil {
            let savedOpacity = defaults.double(forKey: keyHudOpacity)
            self.hudOpacity = min(1.0, max(0.3, savedOpacity))
        } else {
            self.hudOpacity = 0.95
        }

        if defaults.object(forKey: keyFavoritesEnabled) != nil {
            self.isFavoritesEnabled = defaults.bool(forKey: keyFavoritesEnabled)
        } else {
            self.isFavoritesEnabled = false
        }

        checkPermission()
        self.isInitialized = true

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isEnabled && self.hasAccessibilityPermission {
                TranslateMonitor.shared.startMonitoring(with: self.shortcut)
                self.log("SwaprTrans service activated (Shortcut: \(self.shortcut.label))", level: .info)
            }

            // Check if Apple Native Translation model is installed
            if self.provider == .apple {
                Task { @MainActor in
                    let status = await AppleTranslationChecker.checkStatus()
                    if status != .installed {
                        self.log("[Translation] Apple on-device model not downloaded yet, defaulting to Microsoft (Edge)", level: .warning)
                        self.provider = .microsoft
                    }
                }
            }
        }
    }

    public func log(_ message: String, level: SwaprLogLevel = .info) {
        logHandler?(message, level)
    }

    @discardableResult
    public func checkPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let trusted = AXIsProcessTrustedWithOptions(options)
        self.hasAccessibilityPermission = trusted
        return trusted
    }

    public func requestPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        self.hasAccessibilityPermission = trusted
    }

    public func toggleEnabled() {
        checkPermission()
        if !hasAccessibilityPermission {
            log("Accessibility permission required to enable SwaprTrans", level: .error)
            requestPermission()
            return
        }
        isEnabled.toggle()
    }

    private func handleStateChanged() {
        if isEnabled {
            TranslateMonitor.shared.startMonitoring(with: shortcut)
            log("SwaprTrans service started (Trigger shortcut: \(shortcut.label))", level: .success)
        } else {
            TranslateMonitor.shared.stopMonitoring()
            TranslationHudController.shared.hide()
            log("SwaprTrans service stopped", level: .warning)
        }
    }
}
