import SwiftUI
import AppKit
import SwaprTransKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as an accessory app: no Dock icon, stays in the menu bar
        NSApp.setActivationPolicy(.accessory)
        ProcessInfo.processInfo.disableAutomaticTermination("SwaprTrans MenuBar Daemon")
        ProcessInfo.processInfo.disableSuddenTermination()

        // Enable favorites by default for standalone SwaprTrans menu bar app
        if UserDefaults.standard.object(forKey: "swapr_trans_favorites_enabled") == nil {
            SwaprTransConfig.shared.isFavoritesEnabled = true
        }

        // Configure Creem Pro License SDK
        CreemLicenseManager.shared.configure(
            CreemLicenseConfig(
                appName: "SwaprTrans",
                productId: "prod_4DbzRAS3zGQqIxCufT244M",
                purchaseURL: URL(string: "https://www.creem.io/payment/prod_4DbzRAS3zGQqIxCufT244M")!,
                displayPrice: "$6.99",
                proxyBaseURL: URL(string: "https://mac-license.linrol.workers.dev")!,
                storageKey: "swapr_trans_license_info",
                features: [
                    ProFeatureItem(icon: "star.fill", color: .yellow, title: "原生生词本与毫秒检索", subtitle: "基于系统内置 SQLite3 事务存储，零延迟极速搜索"),
                    ProFeatureItem(icon: "square.and.arrow.up.fill", color: .blue, title: "多格式数据导出", subtitle: "一键导出 CSV / JSON，无缝导入 Anki 或欧路词典"),
                    ProFeatureItem(icon: "macbook.and.iphone", color: .purple, title: "多台 Mac 授权与灵活换机", subtitle: "支持多台设备绑定与随时解绑迁移，一次买断终生更新")
                ]
            )
        )

        // Silent background validation for Pro license
        Task {
            await CreemLicenseManager.shared.validateInBackground()
        }

        UpdateManager.shared.startBackgroundCheck()
    }
}

@main
struct SwaprTransApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var config = SwaprTransConfig.shared

    var body: some Scene {
        MenuBarExtra {
            StandaloneMenuBarPopup()
        } label: {
            if config.isEnabled && config.hasAccessibilityPermission {
                Image(systemName: "translate")
            } else {
                Image(systemName: "translate")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
