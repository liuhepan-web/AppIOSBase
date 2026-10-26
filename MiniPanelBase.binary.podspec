# ============================================================================
# MiniPanelBase 的「二进制分发」podspec 模板（类 Android aar + Maven）。
# 源码 pod 用 MiniPanelBase.podspec；本文件用于私有 specs 仓库里的二进制版本。
# 用法见 RELEASE_BINARY.md。把下方 liuhepan-web 换成你的 Git 用户名。
# ============================================================================
Pod::Spec.new do |s|
  s.name             = 'MiniPanelBase'
  s.version          = '0.1.0'
  s.summary          = '涂鸦 App 基础能力库（二进制分发 / XCFramework）'
  s.description      = <<-DESC
    MiniPanelBase 的二进制形态（XCFramework），通过私有 CocoaPods specs 仓库分发，
    等价於 Android 的 aar + Maven：使用者只需 pod 'MiniPanelBase' 一行引用，不拿源码。
  DESC
  s.homepage         = 'https://github.com/liuhepan-web/MiniPanelBase'
  s.license          = { :type => 'MIT' }
  s.author           = { 'dev' => 'dev@example.com' }
  s.source           = { :git => 'https://github.com/liuhepan-web/MiniPanelBase.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.static_framework = true

  # 二进制分发：只暴露 xcframework，不再带源码
  s.vendored_frameworks = 'MiniPanelBase.xcframework'

  # 依赖与源码 pod 保持一致（使用者仍需在自己的 Podfile 引入涂鸦 specs 源）
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
  s.dependency 'ThingSmartBizCore'
  s.dependency 'ThingModuleServices'
  s.dependency 'ThingSmartDeviceKitBizBundle', '~> 7.8.0'
  s.dependency 'ThingSmartPanelBizBundle', '~> 7.8.0'
end
