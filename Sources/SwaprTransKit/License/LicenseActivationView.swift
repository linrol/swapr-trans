import SwiftUI
import AppKit

public struct LicenseActivationView: View {
    @ObservedObject private var manager = LicenseManager.shared
    @State private var licenseKeyInput: String = ""
    @State private var errorMessage: String?
    @State private var successNotice: String?
    @State private var isActivating: Bool = false
    @State private var isDeactivating: Bool = false
    @State private var showDeactivateConfirm: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // 顶部 Header
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: manager.isPro
                                    ? [Color.green.opacity(0.8), Color.teal]
                                    : [Color.purple.opacity(0.8), Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: (manager.isPro ? Color.green : Color.purple).opacity(0.35), radius: 8, y: 3)

                    Image(systemName: manager.isPro ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)

                Text(manager.isPro ? "SwaprTrans Pro 终身授权已生效" : "升级至 SwaprTrans Pro")
                    .font(.system(size: 18, weight: .bold))

                Text(manager.isPro ? "感谢您的支持！您已解锁所有高级特性。" : "一次购买，终生使用。解锁无限收藏与高级生产力。")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 16)

            Divider()

            if manager.isPro, let license = manager.currentLicense {
                // 已激活面板
                activatedSection(license: license)
            } else {
                // 未激活面板
                unactivatedSection()
            }
        }
        .frame(width: 440)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - 未激活视图
    @ViewBuilder
    private func unactivatedSection() -> some View {
        VStack(spacing: 16) {
            // 特权特性清单
            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "star.fill", color: .yellow, title: "原生收藏管理与搜索", subtitle: "极速 SQLite 本地存储，毫秒级即时检索")
                featureRow(icon: "square.and.arrow.up.fill", color: .blue, title: "多格式数据导出", subtitle: "一键导出 CSV、JSON、生词本支持")
                featureRow(icon: "macbook.and.iphone", color: .purple, title: "多台 Mac 授权使用", subtitle: "支持绑定与灵活解绑换机，终身免费版本升级")
            }
            .padding(14)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )

            // 购买链接入口
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("还没有授权码？")
                        .font(.system(size: 12, weight: .medium))
                    Text("一次买断仅需 $6.99 (支持支付宝 / 微信 / 银联 / 信用卡)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: {
                    NSWorkspace.shared.open(LicenseManager.purchaseURL)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.fill")
                        Text("立即购买")
                    }
                    .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.horizontal, 4)

            Divider()

            // 激活码输入区域
            VStack(alignment: .leading, spacing: 8) {
                Text("输入授权激活码")
                    .font(.system(size: 12, weight: .semibold))

                HStack(spacing: 8) {
                    TextField("例如: prod_xxx 或 Creem 授权码", text: $licenseKeyInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 13, design: .monospaced))
                        .disabled(isActivating)

                    Button("粘贴") {
                        if let pasted = NSPasteboard.general.string(forType: .string) {
                            licenseKeyInput = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                if let err = errorMessage {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(err)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 4)

            // 激活按钮
            Button(action: performActivate) {
                HStack(spacing: 6) {
                    if isActivating {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(isActivating ? "正在校验激活..." : "激活 SwaprTrans Pro")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(licenseKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isActivating)
        }
        .padding(20)
    }

    // MARK: - 已激活视图
    @ViewBuilder
    private func activatedSection(license: LicenseInfo) -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "授权状态", value: "已激活 (终身版)")
                infoRow(label: "当前设备", value: license.instanceName)
                if let email = license.customerEmail, !email.isEmpty {
                    infoRow(label: "绑订邮箱", value: email)
                }
                infoRow(label: "授权码", value: maskLicenseKey(license.key))
                infoRow(label: "激活时间", value: formatDate(license.activatedAt))
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )

            if let success = successNotice {
                Text(success)
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }

            Spacer()

            HStack {
                Button("解绑此设备...") {
                    showDeactivateConfirm = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                .controlSize(.regular)
                .disabled(isDeactivating)

                Spacer()

                Button("完成") {
                    NSApp.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(20)
        .confirmationDialog("确定要解绑当前设备吗？", isPresented: $showDeactivateConfirm) {
            Button("解绑设备", role: .destructive) {
                performDeactivate()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("解绑后，本机的 Pro 特权将被锁定，您可以随时将该激活码转移到新 Mac 电脑上使用。")
        }
    }

    // MARK: - 辅助组件

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
        }
    }

    private func maskLicenseKey(_ key: String) -> String {
        guard key.count > 8 else { return "••••••••" }
        let prefix = key.prefix(4)
        let suffix = key.suffix(4)
        return "\(prefix)••••••••\(suffix)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - 交互事件

    private func performActivate() {
        errorMessage = nil
        isActivating = true

        Task {
            do {
                _ = try await manager.activate(key: licenseKeyInput)
                isActivating = false
                successNotice = "恭喜，SwaprTrans Pro 激活成功！"
            } catch {
                isActivating = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func performDeactivate() {
        isDeactivating = true
        Task {
            do {
                try await manager.deactivate()
                isDeactivating = false
                licenseKeyInput = ""
            } catch {
                isDeactivating = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

