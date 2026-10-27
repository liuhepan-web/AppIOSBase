# ============================================================================
# AppIOSBase 的「二进制分发」podspec 模板（类 Android aar + Maven）。
# 源码 pod 用 AppIOSBase.podspec；本文件用于私有 specs 仓库里的二进制版本。
# 用法见 RELEASE_BINARY.md。
# ============================================================================
Pod::Spec.new do |s|
  s.name             = 'AppIOSBase'
  s.version          = '0.2.0'
  s.summary          = '涂鸦 App 基础能力库（二进制分发 / XCFramework）'
  s.description      = <<-DESC
    AppIOSBase 的二进制形态（XCFramework），通过私有 CocoaPods specs 仓库分发，
    等价於 Android 的 aar + Maven：使用者只需 pod 'AppIOSBase' 一行引用，不拿源码。
    功能：注册/登录/家庭列表/切换家庭/设备列表/个人信息/退出登录；无任何面板业务包。
  DESC
  s.homepage         = 'https://github.com/liuhepan-web/AppIOSBase'
  s.license          = { :type => 'MIT' }
  s.author           = { 'liuhepan' => 'liuhepan-web@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/liuhepan-web/AppIOSBase.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.static_framework = true

  # 二进制分发：只暴露 xcframework，不再带源码
  s.vendored_frameworks = 'AppIOSBase.xcframework'

  # 依赖与源码 pod 一致：基础 SDK + 家庭/设备能力（无任何面板业务包）。
  # 其他业务包（配网/小程序等）由使用方在自己的 Podfile 按需添加，未用到不添加。
  # 安全 SDK ThingSmartCryption 由宿主工程以 :path => './' 自行集成，不写进 podspec。
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
  s.dependency 'ThingSmartBizCore'
  s.dependency 'ThingModuleServices'
  s.dependency 'ThingSmartDeviceKit'
end
