import SwiftUI
import AppKit
import SwaprTransKit

struct StandaloneMenuBarPopup: View {
    @ObservedObject var config = SwaprTransConfig.shared
    @ObservedObject var updateManager = UpdateManager.shared
    @ObservedObject var favoritesManager = FavoritesManager.shared
    @State private var isVersionCopied: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "translate")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 14, weight: .bold))
                    Text("SwaprTrans")
                        .font(.system(size: 13, weight: .bold))
                }

                Spacer()

                Circle()
                    .fill(config.isEnabled && config.hasAccessibilityPermission ? Color.green : Color.secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                Text(config.isEnabled && config.hasAccessibilityPermission ? "Active" : "Idle")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            // Update Banner (shows when update available, downloading, or feedback after manual check)
            if updateManager.hasUpdate || updateManager.isDownloading || updateManager.updateError != nil {
                updateBanner
            }

            // Accessibility permission banner if not granted
            if !config.hasAccessibilityPermission {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 13))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Accessibility Permission Needed")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Required to detect selected text across apps and perform in-place text overwrite.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("Grant") {
                        config.requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.12))
                )
            }

            // Core Translation Settings Card
            SwaprTransSettingsView()

            // Saved Translations Entry Row
            if config.isFavoritesEnabled {
                Button(action: {
                    FavoritesWindowController.shared.show()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)

                        Text("Saved Translations")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(favoritesManager.items.count)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Capsule())

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .opacity(0.5)

            // Bottom action row
            bottomActions
        }
        .padding(14)
        .frame(width: 320)
        .onAppear {
            config.checkPermission()
        }
    }

    private var appVersionString: String {
        let version = updateManager.localVersion
        let commit = updateManager.localCommit
        if !commit.isEmpty {
            return "v\(version) (\(commit))"
        }
        return "v\(version)"
    }

    private var updateBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: updateManager.hasUpdate ? "arrow.down.circle.fill" : "info.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 13))

                if let info = updateManager.remoteInfo {
                    Text("New update: v\(info.version)\(info.commit.isEmpty ? "" : " (\(info.commit))")")
                        .font(.system(size: 11, weight: .semibold))
                } else if let err = updateManager.updateError {
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if updateManager.isDownloading {
                    ProgressView()
                        .scaleEffect(0.65)
                        .frame(width: 16, height: 16)
                } else if updateManager.hasUpdate {
                    Button(action: {
                        updateManager.downloadAndInstallUpdate()
                    }) {
                        Text("Update & Restart")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                } else {
                    Button(action: {
                        updateManager.updateError = nil
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if updateManager.isDownloading {
                ProgressView(value: updateManager.downloadProgress, total: 1.0)
                    .progressViewStyle(.linear)
            } else if let msg = updateManager.remoteInfo?.message, !msg.isEmpty {
                Text(msg)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.12))
        )
    }

    private var bottomActions: some View {
        HStack(spacing: 8) {
            // Version with copy button
            Button(action: {
                let textToCopy = appVersionString
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(textToCopy, forType: .string)
                isVersionCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isVersionCopied = false
                }
            }) {
                Text(isVersionCopied ? "Copied!" : appVersionString)
                    .font(.system(size: 11))
                    .foregroundColor(isVersionCopied ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .help("Click to copy version")

            // Check for updates button
            Button(action: {
                Task {
                    await updateManager.checkForUpdates(silent: false)
                }
            }) {
                if updateManager.isChecking {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(updateManager.isChecking || updateManager.isDownloading)
            .help("Check for updates")

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
    }
}
