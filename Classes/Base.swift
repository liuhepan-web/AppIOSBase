import Foundation

extension Notification.Name {
    /// Base 发出：登录成功。App 层监听后切换到 Features 主页。
    /// 用通知解耦，保证 Base 模块不反向依赖 Features / App。
    public static let baseDidLogin = Notification.Name("BaseDidLogin")
}

/// Base 模块门面：负责 SDK 初始化、登录态/家庭态查询，并向业务包注册家庭协议。
///
/// 设计目标：把「账户 + 家庭 + 设备」这套基础能力收敛为自包含模块。
/// 后续新建工程时，直接把 `Base/` 整个目录拷过去、调用 `Base.configure(...)` 即可，
/// 不需要重写登录/注册/配网/家庭/设备列表。Base 不依赖 Features，单向依赖。
public enum Base {

    /// App 启动时调用一次：初始化基础 SDK + 业务包框架，并注册家庭协议。
    public static func configure(appKey: String, appSecret: String) {
        ThingSmartSDK.sharedInstance().start(withAppKey: appKey, secretKey: appSecret)
        ThingSmartBusinessExtensionConfig.setupConfig()
    }

    /// 是否已登录
    public static var isLoggedIn: Bool {
        return ThingSmartUser.sharedInstance().isLogin
    }

    /// 当前家庭 ID（0 表示未选择）
    public static var currentHomeId: Int64 {
        return DemoCurrentHomeStore.currentHomeId
    }

    /// 退出登录并清空家庭与登录信息
    public static func logout(completion: @escaping () -> Void) {
        ThingSmartUser.sharedInstance().loginOut({
            DemoCurrentHomeStore.clearAll()
            completion()
        }, failure: { _ in
            DemoCurrentHomeStore.clearAll()
            completion()
        })
    }

    // MARK: - 界面工厂（对外只返回 UIViewController，VC 实现保持 internal，
    // 避免 public 类的 override / 协议方法被迫 public）

    public static func makeLoginViewController() -> UIViewController { LoginViewController() }
    public static func makeRegisterViewController() -> UIViewController { RegisterViewController() }
}
