# AppIOSBase

涂鸦 App 基础能力库（注册 / 登录 / 配网 / 家庭 / 设备列表），**可跨工程复用的 CocoaPod**。
源码独立于宿主 App，不在宿主工程内 —— 推到 git 后，别人下载即可用一行 Podfile 引用。

## 特点
- 独立 pod，宿主工程不内嵌 Base 源码。
- 对外只暴露少量 public 接口（`Base` 门面 + `DemoConfig` / `DemoCurrentHomeStore` 等）；
  视图控制器实现保持 internal，用 `Base.makeXxxViewController()` 工厂方法获取。
- 内部用 `@_exported import` 统一引入涂鸦 SDK 模块，调用方无需关心 Tuya 头文件。

## 安装

### 方式一：本地路径（本仓库 Demo 在用，clone 整个仓库即可用）
```ruby
pod 'AppIOSBase', :path => './AppIOSBase'
```

### 方式二：Git（推荐给其他项目复用，非本地专属）
把本 `AppIOSBase/` 目录推到独立 git 仓库后，他人在 Podfile 里：
```ruby
pod 'AppIOSBase', :git => 'https://github.com/liuhepan-web/AppIOSBase.git', :tag => '0.2.0'
```
然后执行 `pod install`。

> **本库只依赖基础 SDK（重构后只做登录/注册/SDK初始化/登录态）**：
> - **基础 SDK（必带）**：`ThingSmartHomeKit` + `ThingSmartBusinessExtensionKit`。
> - **安全 SDK `ThingSmartCryption`**：由宿主工程以 `:path => './'` 自行集成，**不**写进本库依赖。
> - **业务包（设备面板 / 配网 / 小程序 / 家庭 等）**：本库不再包含相关界面，**由使用方在自己的 Podfile 里按需添加，没有需要就不添加**。
>   可参考同账号下的 `MiniPanelDemoIOS` 示例，其 `Features/` 已演示设备列表 / 家庭选择 / 配网 / 面板等界面如何接。
>   宿主 Podfile 需包含涂鸦 specs 源：`source 'https://github.com/tuya/tuya-pod-specs.git'`

## 在其他 Demo 中复用（一步引用）
AppIOSBase 已经是一个**独立、可跨工程复用**的 pod。新建任意 iOS 工程，只需：

1. 在 Podfile 里加一行（方式二的 `:git` 引用）。
2. 在 App 启动时调用 `Base.configure(...)` 初始化。
3. 用 `Base.makeLoginViewController()` / `Base.makeRegisterViewController()` 拿登录注册页，监听 `.baseDidLogin` 切主页。
   设备列表 / 家庭选择 / 配网 / 面板等业务包界面不在本库，请使用方集成对应业务包后自行实现。

### 新工程 Podfile（最小可用）
```ruby
source 'https://github.com/tuya/tuya-pod-specs.git'
source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

target 'NewDemo' do
  # 1) 安全 SDK（涂鸦平台下载 ios_core_sdk.tar.gz，解压到 Podfile 同级目录）
  pod "ThingSmartCryption", :path => './'

  # 2) 基础 + 业务拓展 SDK（v7.8.0）
  pod "ThingSmartHomeKit", "~> 7.8.0"
  pod "ThingSmartBusinessExtensionKit", "~> 7.8.0"

  # 3) 业务包核心（启动业务包 / 协议）
  pod "ThingSmartBizCore"
  pod "ThingModuleServices"

  # 4) 你用到的业务包（按需求增删；AppIOSBase 内部用到：小程序 / 面板 / 设备 / 配网）
  pod "ThingSmartMiniAppBizBundle", "~> 7.8.0"
  pod "ThingSmartPanelBizBundle", "~> 7.8.0"
  pod "ThingSmartDeviceKitBizBundle", "~> 7.8.0"
  pod "ThingSmartActivatorBizBundle", "~> 7.8.0"

  # 5) 复用 AppIOSBase（一行引用，非本地）
  pod 'AppIOSBase', :git => 'https://github.com/liuhepan-web/AppIOSBase.git', :tag => '0.2.0'
end
```

### App 启动初始化（AppDelegate.swift）
```swift
import UIKit
import AppIOSBase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 1) 初始化 Base（填入你自己的 AppKey / AppSecret）
        Base.configure(appKey: "你的AppKey", appSecret: "你的AppSecret")

        // 2) 未登录 → 登录页；已登录 → 使用方自己的主页（需集成业务包）
        let root = Base.isLoggedIn
            ? UIViewController() /* 使用方自己的主页，需集成业务包 */
            : Base.makeLoginViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()

        // 3) 监听登录成功，切到主页
        NotificationCenter.default.addObserver(
            forName: .baseDidLogin, object: nil, queue: .main
        ) { [weak self] _ in
            self?.window?.rootViewController = Base.makeHomePickerViewController()
        }
        return true
    }
}
```
> 说明：`DemoConfig` 只是本 Demo 存放 appKey/appSecret 的便利结构；新工程直接把字符串传给
> `Base.configure(appKey:secret:)` 即可，无需引入 `DemoConfig`。

## 用法
```swift
import AppIOSBase

// App 启动时初始化一次
Base.configure(appKey: "你的AppKey", appSecret: "你的AppSecret")

// 登录 / 注册
let login = Base.makeLoginViewController()      // 登录页
let reg   = Base.makeRegisterViewController()   // 注册页
// 设备列表 / 家庭选择 / 配网 / 面板等业务包界面由使用方集成业务包后自行实现

// 监听登录成功（App 层据此切换根控制器）
NotificationCenter.default.addObserver(
    forName: .baseDidLogin, object: nil, queue: .main
) { _ in /* 切换到主页 */ }
```

## 对外 API
- `Base`：`configure` / `isLoggedIn` / `currentHomeId` / `logout` /
  `makeLoginViewController` / `makeRegisterViewController`
- 设备列表 / 家庭选择 / 配网 / 设备面板等业务包界面**不在本库**，请使用方集成对应业务包后自行实现
  （参考 `MiniPanelDemoIOS` 示例的 `Features/`）。
- `Notification.Name.baseDidLogin`：登录成功通知
- `DemoConfig`：appKey / appSecret / appId / appScheme / sampleMiniAppId
- `DemoCurrentHomeStore`：当前家庭与登录态本地存储
- `UIViewController.showAlert(_:)`、`UIButton.setAction(_:)`：UI 便捷方法

## 发布到 git（让别人可用）—— 你需要做的步骤
1. 在 GitHub / 公司 Git 新建**空仓库**（如 `AppIOSBase`）。
2. 本目录已是独立 git 仓库（commit `02870b3`），直接加远程并推送：
   ```bash
   cd /path/to/AppIOSBase
   git remote add origin https://github.com/liuhepan-web/AppIOSBase.git
   git tag 0.2.0
   git push -u origin main --tags
   ```
3. 把 `AppIOSBase.podspec` 里 `s.source` / `s.homepage` 的 `liuhepan-web` 换成你的用户名
   （文件内已标注），然后 `git commit -am "fix: use real repo url"` + `git push`。
4. 别人即可用 `pod 'AppIOSBase', :git => '...'` 引用。

## （可选）二进制发布：XCFramework + 私有 Specs 仓库（类 Android aar + Maven）
如果你希望像 Android 的 aar + Maven 那样**只分发二进制**、不暴露源码，见 `RELEASE_BINARY.md`。
已为你准备好 `Scripts/build_xcframework.sh` 与 `AppIOSBase.binary.podspec` 模板，
在 Mac 上跑一次脚本即可产出 `AppIOSBase.xcframework`，再推到私有 specs 仓库即可
用 `pod 'AppIOSBase', '0.2.0'` 一行引用，无需 `:git` 也无需源码。
