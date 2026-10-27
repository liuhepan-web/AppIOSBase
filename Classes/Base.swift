import Foundation
import ThingSmartBizCore
import ThingSmartDeviceKit
import ThingModuleServices

extension Notification.Name {
    /// Base 发出：登录成功。App 层监听后切换到主页。
    /// 用通知解耦，保证 Base 模块不反向依赖 App / Features。
    public static let baseDidLogin = Notification.Name("BaseDidLogin")

    /// Base 发出：已退出登录（Base.logout 内部发出）。App 层监听后切回登录页。
    public static let baseDidLogout = Notification.Name("BaseDidLogout")
}

/// Base 模块门面。
/// 功能范围：SDK 初始化、注册、登录、家庭列表/切换（含创建家庭）、设备列表、个人信息、退出登录。
/// 家庭协议（ThingFamilyProtocol）在 configure 内自动注册，使用方无需手动注册。
///
/// 设备面板：不在本库。各 demo 有自己的原生面板，启动时通过 `devicePanelHandler`
/// 注册跳转逻辑，设备列表点击设备时回调。
public enum Base {

    /// 设备点击 → 原生面板跳转钩子：由各 demo 注册自己的原生面板跳转。
    /// 未注册时，设备列表点击仅展示设备信息。
    public static var devicePanelHandler: ((_ device: ThingSmartDeviceModel,
                                            _ navigationController: UINavigationController?) -> Void)?

    /// App 启动时调用一次：初始化基础 SDK + 业务包框架，并注册家庭协议。
    public static func configure(appKey: String, appSecret: String) {
        ThingSmartSDK.sharedInstance().start(withAppKey: appKey, secretKey: appSecret)
        ThingSmartBusinessExtensionConfig.setupConfig()
        ThingSmartBizCore.sharedInstance().registerService(ThingFamilyProtocol.self,
                                                           withInstance: FamilyService.shared)
    }

    /// 是否已登录
    public static var isLoggedIn: Bool {
        return ThingSmartUser.sharedInstance().isLogin
    }

    /// 当前家庭 ID（0 表示未选择）
    public static var currentHomeId: Int64 {
        return DemoCurrentHomeStore.currentHomeId
    }

    /// 退出登录：清空家庭与登录信息，并发出 `.baseDidLogout` 通知
    public static func logout(completion: @escaping () -> Void) {
        ThingSmartUser.sharedInstance().loginOut({
            DemoCurrentHomeStore.clearAll()
            NotificationCenter.default.post(name: .baseDidLogout, object: nil)
            completion()
        }, failure: { _ in
            DemoCurrentHomeStore.clearAll()
            NotificationCenter.default.post(name: .baseDidLogout, object: nil)
            completion()
        })
    }

    // MARK: - 界面工厂（对外只返回 UIViewController，VC 实现保持 internal）

    public static func makeLoginViewController() -> UIViewController { LoginViewController() }
    public static func makeRegisterViewController() -> UIViewController { RegisterViewController() }
    public static func makeHomePickerViewController() -> UIViewController { HomePickerViewController() }
    public static func makeDeviceListViewController() -> UIViewController { DeviceListViewController() }
    public static func makeProfileViewController() -> UIViewController { ProfileViewController() }
}
