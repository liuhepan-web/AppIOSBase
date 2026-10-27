import Foundation
import ThingModuleServices

/// 实现 ThingFamilyProtocol，向业务包提供「当前家庭」。
/// 对应 Android 的 BizBundleFamilyServiceImpl。
/// 用户在 HomePicker 切换家庭后写入 DemoCurrentHomeStore，这里实时读取；
/// Base.configure 内部已自动注册，使用方无需手动注册。
final class FamilyService: NSObject, ThingFamilyProtocol {

    static let shared = FamilyService()

    func getCurrentHome() -> ThingSmartHome! {
        let homeId = DemoCurrentHomeStore.currentHomeId
        guard homeId != 0 else { return nil }
        return ThingSmartHome(homeId: homeId)
    }
}
