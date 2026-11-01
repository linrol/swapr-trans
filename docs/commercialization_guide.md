# SwaprTrans 商业化与授权系统架构 (Creem + Cloudflare Worker)

## 1. 核心商品与支付参数

- **平台**: [Creem.io](https://www.creem.io)
- **产品名称**: SwaprTrans Pro (Lifetime License)
- **价格**: \$6.99 (终身买断)
- **支付链接 (Payment Link)**: `https://www.creem.io/payment/prod_4DbzRAS3zGQqIxCufT244M`
- **Product ID**: `prod_4DbzRAS3zGQqIxCufT244M`
- **支持支付方式**: 支付宝 (Alipay)、微信支付 (WeChat Pay)、银联 (UnionPay)、信用卡 (Credit Cards)、Apple Pay 等

---

## 2. 安全架构（Cloudflare Worker 代理鉴权）

为了保护商户的 **Full-Access API 密钥** 绝不泄露到开源客户端或逆向工程中，系统采用标准的无状态代理鉴权架构：

```
[SwaprTrans macOS App] 
        │ (无任何商户私钥)
        ▼
[Cloudflare Worker 代理端点]
        │ (在 Cloudflare 环境变量中安全注入 CREEM_API_KEY)
        ▼
[Creem 官方 API (https://api.creem.io/v1/licenses/...)]
```

### 2.1 客户端调用接口
- `POST <worker-domain>/activate`
- `POST <worker-domain>/deactivate`
- `POST <worker-domain>/validate`

客户端仅需向代理发送用户输入的激活码和机器识别名，无需携带商户 Secret Key。

---

## 3. 客户端模块结构

- [`LicenseManager.swift`](file:///Users/linrol/work/sourcecode/gitee/swapr-trans/Sources/SwaprTransKit/License/LicenseManager.swift): 负责与安全代理交互、机器标识上报、离线授权缓存和后台静默校验。
- [`LicenseActivationView.swift`](file:///Users/linrol/work/sourcecode/gitee/swapr-trans/Sources/SwaprTransKit/License/LicenseActivationView.swift): 现代化 SwiftUI 弹窗，支持一键购买跳转、激活码校验、已激活状态管理及解绑设备。
- [`LicenseWindowController.swift`](file:///Users/linrol/work/sourcecode/gitee/swapr-trans/Sources/SwaprTransKit/License/LicenseWindowController.swift): 单例窗口控制器。
- [`MenuBarPopup.swift`](file:///Users/linrol/work/sourcecode/gitee/swapr-trans/Sources/SwaprTrans/MenuBarPopup.swift): 菜单栏弹窗常驻入口。
