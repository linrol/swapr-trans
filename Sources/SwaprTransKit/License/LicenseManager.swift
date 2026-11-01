import Foundation
import Combine

/// Creem License 激活信息
public struct LicenseInfo: Codable, Sendable, Equatable {
    public let key: String
    public let instanceId: String?
    public let instanceName: String
    public let status: String
    public let activatedAt: Date
    public let customerEmail: String?

    public init(
        key: String,
        instanceId: String? = nil,
        instanceName: String,
        status: String = "active",
        activatedAt: Date = Date(),
        customerEmail: String? = nil
    ) {
        self.key = key
        self.instanceId = instanceId
        self.instanceName = instanceName
        self.status = status
        self.activatedAt = activatedAt
        self.customerEmail = customerEmail
    }
}

/// 授权错误定义
public enum LicenseError: LocalizedError, Sendable {
    case invalidKey
    case networkError(String)
    case serverError(String)
    case maxActivationsReached
    case notActivated

    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "激活码无效或不存在，请检查输入。"
        case .networkError(let msg):
            return "网络连接失败：\(msg)"
        case .serverError(let msg):
            return "授权验证失败：\(msg)"
        case .maxActivationsReached:
            return "该激活码激活设备数量已达到上限，请先解绑其他设备。"
        case .notActivated:
            return "当前尚未激活 Pro 授权。"
        }
    }
}

/// 管理 SwaprTrans Pro 许可证激活、校验与解绑
@MainActor
public final class LicenseManager: ObservableObject {
    public static let shared = LicenseManager()

    /// Creem 购买与配置常量
    public static let purchaseURL = URL(string: "https://www.creem.io/payment/prod_4DbzRAS3zGQqIxCufT244M")!
    public static let productId = "prod_4DbzRAS3zGQqIxCufT244M"
    
    /// Cloudflare Worker 代理服务地址（保护商户 API Key 绝不上端）
    /// 格式类似: https://swaprtrans-license.<your-subdomain>.workers.dev
    public static var proxyBaseURL: String = "https://swaprtrans-license.workers.dev"
    private static let storageKey = "swapr_trans_license_info"

    @Published public private(set) var isPro: Bool = false
    @Published public private(set) var currentLicense: LicenseInfo?
    @Published public private(set) var isBusy: Bool = false

    private init() {
        loadSavedLicense()
    }

    /// 本机设备名称标识
    public var machineName: String {
        Host.current().localizedName ?? ProcessInfo.processInfo.hostName
    }

    // MARK: - 存储与恢复

    private func loadSavedLicense() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let info = try? JSONDecoder().decode(LicenseInfo.self, from: data) else {
            self.isPro = false
            self.currentLicense = nil
            return
        }

        self.currentLicense = info
        self.isPro = (info.status == "active")
    }

    private func saveLicense(_ info: LicenseInfo?) {
        self.currentLicense = info
        self.isPro = (info?.status == "active")

        if let info = info, let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.storageKey)
        }
    }

    // MARK: - 激活 (Activate)

    public func activate(key rawKey: String) async throws -> LicenseInfo {
        let key = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            throw LicenseError.invalidKey
        }

        isBusy = true
        defer { isBusy = false }

        guard let url = URL(string: "\(Self.proxyBaseURL)/activate") else {
            throw LicenseError.serverError("Invalid API URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "key": key,
            "instance_name": machineName
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw LicenseError.networkError(error.localizedDescription)
        }

        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? 500

        // 解析响应
        let json = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]

        if statusCode == 200 || statusCode == 201 {
            // 激活成功
            let instanceId = json["instance_id"] as? String ?? json["id"] as? String
            let customerEmail = json["customer_email"] as? String ?? (json["customer"] as? [String: Any])?["email"] as? String

            let info = LicenseInfo(
                key: key,
                instanceId: instanceId,
                instanceName: machineName,
                status: "active",
                activatedAt: Date(),
                customerEmail: customerEmail
            )
            saveLicense(info)
            return info
        } else {
            let messages = json["message"] as? [String] ?? [json["message"] as? String ?? ""]
            let errorText = messages.first ?? "未知错误"

            if errorText.localizedCaseInsensitiveContains("not found") {
                throw LicenseError.invalidKey
            } else if errorText.localizedCaseInsensitiveContains("limit") || errorText.localizedCaseInsensitiveContains("max") {
                throw LicenseError.maxActivationsReached
            } else {
                throw LicenseError.serverError(errorText.isEmpty ? "状态码 \(statusCode)" : errorText)
            }
        }
    }

    // MARK: - 解绑 (Deactivate)

    public func deactivate() async throws {
        guard let current = currentLicense else {
            throw LicenseError.notActivated
        }

        isBusy = true
        defer { isBusy = false }

        if let instanceId = current.instanceId,
           let url = URL(string: "\(Self.proxyBaseURL)/deactivate") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10

            let body: [String: Any] = [
                "key": current.key,
                "instance_id": instanceId
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            _ = try? await URLSession.shared.data(for: request)
        }

        saveLicense(nil)
    }

    // MARK: - 校验 (Validate - 悄悄在后台校准)

    public func validateInBackground() async {
        guard let current = currentLicense, let instanceId = current.instanceId,
              let url = URL(string: "\(Self.proxyBaseURL)/validate") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        let body: [String: Any] = [
            "key": current.key,
            "instance_id": instanceId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse else {
            return // 网络不通时不剥夺已激活权限，支持离线
        }

        if http.statusCode == 404 || http.statusCode == 400 {
            // 授权被吊销或退款
            saveLicense(nil)
        }
    }
}
