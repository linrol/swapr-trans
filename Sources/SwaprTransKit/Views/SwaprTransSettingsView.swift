import SwiftUI
import AppKit

public struct SwaprTransSettingsView: View {
    @ObservedObject public var config: SwaprTransConfig = SwaprTransConfig.shared
    @State private var modelDownloadWarning: String? = nil

    public let isCollapsible: Bool
    private var externalExpanded: Binding<Bool>?
    @State private var internalExpanded: Bool

    private var isExpanded: Binding<Bool> {
        if let external = externalExpanded {
            return external
        }
        return $internalExpanded
    }

    public init(isCollapsible: Bool = false, defaultExpanded: Bool = false) {
        self.isCollapsible = isCollapsible
        self.externalExpanded = nil
        self._internalExpanded = State(initialValue: isCollapsible ? defaultExpanded : true)
    }

    public init(isCollapsible: Bool, isExpanded: Binding<Bool>) {
        self.isCollapsible = isCollapsible
        self.externalExpanded = isExpanded
        self._internalExpanded = State(initialValue: isExpanded.wrappedValue)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            // Header Toggle Row
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.accentColor)
                    Text("Auto Translation")
                        .font(.system(size: 12, weight: .medium))
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { config.isEnabled },
                    set: { _ in config.toggleEnabled() }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .labelsHidden()
                .controlSize(.mini)

                if isCollapsible {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.wrappedValue.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !isCollapsible || isExpanded.wrappedValue {
                // Setting items always visible regardless of toggle state
                VStack(spacing: 5) {
                // Shortcut selection
                HStack {
                    Text("Shortcut:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Picker("", selection: $config.shortcut) {
                        ForEach(TranslationShortcut.presets) { sc in
                            Text(sc.label).tag(sc)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .controlSize(.mini)
                }

                // Provider selection
                HStack {
                    Text("Provider:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Picker("", selection: Binding(
                        get: { config.provider },
                        set: { newProvider in
                            if newProvider == .apple {
                                Task { @MainActor in
                                    let status = await AppleTranslationChecker.checkStatus()
                                    switch status {
                                    case .installed:
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            modelDownloadWarning = nil
                                        }
                                        config.provider = .apple
                                    case .notDownloaded:
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            modelDownloadWarning = "The on-device Chinese ⇋ English model is not downloaded.\nGo to: System Settings ➔ General ➔ Language & Region ➔ Translation Languages"
                                        }
                                    case .unsupported:
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            modelDownloadWarning = "Apple on-device translation requires macOS 15.0 Sequoia or newer."
                                        }
                                    }
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    modelDownloadWarning = nil
                                }
                                config.provider = newProvider
                            }
                        }
                    )) {
                        ForEach(TranslationProvider.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .controlSize(.mini)
                }

                // Inline warning banner for Apple Translation model status
                if let warning = modelDownloadWarning {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                            .padding(.top, 1)

                        Text(warning)
                            .font(.system(size: 10))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                modelDownloadWarning = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary.opacity(0.6))
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.15))
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Auto dismiss delay
                HStack {
                    Text("Auto Dismiss:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Picker("", selection: $config.autoDismissSeconds) {
                        Text("Never (Default)").tag(0)
                        Text("5 seconds").tag(5)
                        Text("10 seconds").tag(10)
                        Text("15 seconds").tag(15)
                        Text("20 seconds").tag(20)
                        Text("30 seconds").tag(30)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .controlSize(.mini)
                }

                // Window Opacity
                HStack {
                    Text("Window Opacity:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Button("Preview") {
                        TranslationHudController.shared.show(
                            original: "SwaprTrans dynamic sizing and transparency preview.",
                            translated: "SwaprTrans dynamically adapts HUD size with frosted glass preview.",
                            direction: "EN ➔ ZH",
                            provider: config.provider.displayName,
                            targetPid: 0
                        )
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 9.5))
                    .foregroundColor(.accentColor)

                    Spacer()

                    Slider(
                        value: $config.hudOpacity,
                        in: 0.3...1.0,
                        step: 0.05
                    )
                    .frame(width: 80)
                    .tint(.accentColor)

                    Text("\(Int(config.hudOpacity * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 32, alignment: .trailing)
                }
            }
            .padding(.top, 2)

            Text("Select text in any app, then press \(config.shortcut.label) to translate and replace/copy")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 1)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
        )
    }
}
