import Foundation

/// 涂鸦平台配置。请在涂鸦开发者平台（platform.tuya.com）创建 iOS App SDK 后填写。
/// 注意：appKey / appSecret / BundleId 三者必须与平台完全一致，否则 SDK 无法使用。
public struct DemoConfig {

    /// App 唯一凭证（SDK 详情页 → 获取密钥 → AppKey）
    public static let appKey = "t3kfyh3f45utvyeptrxh"

    /// App 密钥（SDK 详情页 → 获取密钥 → AppSecret）
    public static let appSecret = "ajh9nrdeaerh3yu9jvq4jtpfy7hnjae5"

    /// 应用 ID（platform.tuya.com/oem/app?id=xxxxxx 中的 xxxxxx，数字）
    public static let appId: Int = 1319850661

    /// 渠道标识符（platform.tuya.com 上对应 SDK 的渠道标识符，需与 thing_custom_config.json 的 appScheme 一致）
    public static let appScheme = "ThingSmart"

    /// 调试用示例小程序 ID，可改成你自己在小程序后台创建的小程序 ID
    public static let sampleMiniAppId = "tyt6wgxqavcvdq0an2"
}
