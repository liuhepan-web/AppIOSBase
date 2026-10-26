import Foundation

/// 实现 ThingFamilyProtocol，向业务包（设备面板 / 小程序）提供「当前家庭」。
/// 对应 Android 的 BizBundleFamilyServiceImpl。
/// 用户在 HomePicker 选择家庭后写入 DemoCurrentHomeStore，这里实时读取，
/// 因此只需注册一次实例。
final class FamilyService: NSObject, ThingFamilyProtocol {

    static let shared = FamilyService()

    func getCurrentHome() -> ThingSmartHome! {
        let homeId = DemoCurrentHomeStore.currentHomeId
        guard homeId != 0 else { return nil }
        return ThingSmartHome(homeId: homeId)
    }
}
