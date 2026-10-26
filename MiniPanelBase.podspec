Pod::Spec.new do |s|
  s.name             = 'MiniPanelBase'
  s.version          = '0.1.0'
  s.summary          = '涂鸦 App 基础能力库：注册/登录/配网/家庭/设备列表'
  s.description      = <<-DESC
    MiniPanelBase 把「账户 + 家庭 + 设备」这套基础能力（注册、登录、配网、家庭选择、
    设备列表）收敛为自包含模块。新工程只需 Podfile 加一行引用即可复用，无需重写。
  DESC
  s.homepage         = 'https://github.com/liuhepan-web/MiniPanelBase'
  s.license          = { :type => 'MIT' }
  s.author           = { 'liuhepan' => 'liuhepan-web@users.noreply.github.com' }
  # 用 git 源，保证推到 git 后他人可下载复用（不是本地专属）。
  # 使用者在 Podfile 里用 :git => '你的仓库地址' 引用时会覆盖此处；本地 Demo 用 :path 引用时忽略此项。
  s.source           = { :git => 'https://github.com/liuhepan-web/MiniPanelBase.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Classes/**/*.{swift}'

  # 本工程未全局 use_frameworks!，用静态 framework 形态产出 Swift 模块，
  # 使宿主 App 能 `import MiniPanelBase`。
  s.static_framework = true

  # 运行与编译所需的涂鸦 SDK 依赖（与 Base 内 @_exported import 的模块对应）
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
  s.dependency 'ThingSmartBizCore'
  s.dependency 'ThingModuleServices'
  s.dependency 'ThingSmartDeviceKitBizBundle', '~> 7.8.0'
  s.dependency 'ThingSmartPanelBizBundle', '~> 7.8.0'
end
