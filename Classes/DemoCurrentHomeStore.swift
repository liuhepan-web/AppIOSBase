import Foundation

/// 本地持久化：当前家庭 ID 与登录账号（用于下次冷启动预填 / 自动登录）。
/// 对应 Android 的 DemoCurrentHomeStore。
public enum DemoCurrentHomeStore {

    // MARK: - 当前家庭

    private static let homeIdKey = "demo_current_home_id"

    public static var currentHomeId: Int64 {
        get { UserDefaults.standard.object(forKey: homeIdKey) as? Int64 ?? 0 }
        set { UserDefaults.standard.set(newValue, forKey: homeIdKey) }
    }

    public static func clearCurrentHome() {
        UserDefaults.standard.removeObject(forKey: homeIdKey)
    }

    // MARK: - 登录账号（仅用于预填与自动登录，不保存明文敏感信息到 Keychain）

    private static let loginCountryKey = "demo_login_country"
    private static let loginAccountKey = "demo_login_account"
    private static let loginPasswordKey = "demo_login_password"

    public static func saveLoginCredentials(country: String, account: String, password: String) {
        let ud = UserDefaults.standard
        ud.set(country, forKey: loginCountryKey)
        ud.set(account, forKey: loginAccountKey)
        ud.set(password, forKey: loginPasswordKey)
    }

    public static func clearLoginCredentials() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: loginCountryKey)
        ud.removeObject(forKey: loginAccountKey)
        ud.removeObject(forKey: loginPasswordKey)
    }

    public static func hasSavedLoginCredentials() -> Bool {
        let account = UserDefaults.standard.string(forKey: loginAccountKey) ?? ""
        let password = UserDefaults.standard.string(forKey: loginPasswordKey) ?? ""
        return !account.isEmpty && !password.isEmpty
    }

    public static func getSavedCountry() -> String {
        UserDefaults.standard.string(forKey: loginCountryKey) ?? "86"
    }

    public static func getSavedAccount() -> String {
        UserDefaults.standard.string(forKey: loginAccountKey) ?? ""
    }

    public static func getSavedPassword() -> String {
        UserDefaults.standard.string(forKey: loginPasswordKey) ?? ""
    }

    /// 清空家庭与登录信息（退出登录时调用）
    public static func clearAll() {
        clearCurrentHome()
        clearLoginCredentials()
    }
}
