# MiniPanelBase

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
pod 'MiniPanelBase', :path => './MiniPanelBase'
```

### 方式二：Git（推荐给其他项目复用，非本地专属）
把本 `MiniPanelBase/` 目录推到独立 git 仓库后，他人在 Podfile 里：
```ruby
pod 'MiniPanelBase', :git => 'https://github.com/liuhepan-web/MiniPanelBase.git', :tag => '0.1.0'
```
然后执行 `pod install`。

> 本库依赖涂鸦 SDK，宿主 Podfile 需包含涂鸦 specs 源：
> `source 'https://github.com/tuya/tuya-pod-specs.git'`
> 并按需在宿主工程集成 Tuya 业务包（配网 / 家庭 / 小程序等）与安全 SDK。

## 在其他 Demo 中复用（一步引用）
MiniPanelBase 已经是一个**独立、可跨工程复用**的 pod。新建任意 iOS 工程，只需：

1. 在 Podfile 里加一行（方式二的 `:git` 引用）。
2. 在 App 启动时调用 `Base.configure(...)` 初始化。
3. 用 `Base.makeXxxViewController()` 拿页面，监听 `.baseDidLogin` 切主页。

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

  # 4) 你用到的业务包（按需求增删；MiniPanelBase 内部用到：小程序 / 面板 / 设备 / 配网）
  pod "ThingSmartMiniAppBizBundle", "~> 7.8.0"
  pod "ThingSmartPanelBizBundle", "~> 7.8.0"
  pod "ThingSmartDeviceKitBizBundle", "~> 7.8.0"
  pod "ThingSmartActivatorBizBundle", "~> 7.8.0"

  # 5) 复用 MiniPanelBase（一行引用，非本地）
  pod 'MiniPanelBase', :git => 'https://github.com/liuhepan-web/MiniPanelBase.git', :tag => '0.1.0'
end
```

### App 启动初始化（AppDelegate.swift）
```swift
import UIKit
import MiniPanelBase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 1) 初始化 Base（填入你自己的 AppKey / AppSecret）
        Base.configure(appKey: "你的AppKey", appSecret: "你的AppSecret")

        // 2) 未登录 → 登录页；已登录 → 家庭选择页
        let root = Base.isLoggedIn
            ? Base.makeHomePickerViewController()
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
import MiniPanelBase

// App 启动时初始化一次
Base.configure(appKey: "你的AppKey", appSecret: "你的AppSecret")

// 登录 / 注册 / 家庭 / 设备
let login = Base.makeLoginViewController()      // 登录页
let reg   = Base.makeRegisterViewController()   // 注册页
let home  = Base.makeHomePickerViewController() // 家庭选择
let dev   = Base.makeDeviceListViewController() // 设备列表

// 监听登录成功（App 层据此切换根控制器）
NotificationCenter.default.addObserver(
    forName: .baseDidLogin, object: nil, queue: .main
) { _ in /* 切换到主页 */ }
```

## 对外 API
- `Base`：`configure` / `isLoggedIn` / `currentHomeId` / `logout` /
  `makeLoginViewController` / `makeRegisterViewController` / `makeHomePickerViewController` / `makeDeviceListViewController`
- `Notification.Name.baseDidLogin`：登录成功通知
- `DemoConfig`：appKey / appSecret / appId / appScheme / sampleMiniAppId
- `DemoCurrentHomeStore`：当前家庭与登录态本地存储
- `UIViewController.showAlert(_:)`、`UIButton.setAction(_:)`：UI 便捷方法

## 发布到 git（让别人可用）—— 你需要做的步骤
1. 在 GitHub / 公司 Git 新建**空仓库**（如 `MiniPanelBase`）。
2. 本目录已是独立 git 仓库（commit `02870b3`），直接加远程并推送：
   ```bash
   cd /path/to/MiniPanelBase
   git remote add origin https://github.com/liuhepan-web/MiniPanelBase.git
   git tag 0.1.0
   git push -u origin main --tags
   ```
3. 把 `MiniPanelBase.podspec` 里 `s.source` / `s.homepage` 的 `liuhepan-web` 换成你的用户名
   （文件内已标注），然后 `git commit -am "fix: use real repo url"` + `git push`。
4. 别人即可用 `pod 'MiniPanelBase', :git => '...'` 引用。

## （可选）二进制发布：XCFramework + 私有 Specs 仓库（类 Android aar + Maven）
如果你希望像 Android 的 aar + Maven 那样**只分发二进制**、不暴露源码，见 `RELEASE_BINARY.md`。
已为你准备好 `Scripts/build_xcframework.sh` 与 `MiniPanelBase.binary.podspec` 模板，
在 Mac 上跑一次脚本即可产出 `MiniPanelBase.xcframework`，再推到私有 specs 仓库即可
用 `pod 'MiniPanelBase', '0.1.0'` 一行引用，无需 `:git` 也无需源码。
