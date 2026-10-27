Pod::Spec.new do |s|
  s.name             = 'AppIOSBase'
  s.version          = '0.2.0'
  s.summary          = '涂鸦 App 基础能力库：注册/登录/家庭列表/切换家庭/设备列表/个人信息/退出登录'
  s.description      = <<-DESC
    AppIOSBase 把 App 通用基础能力收敛为自包含模块：SDK 初始化、注册、登录、
    家庭列表与切换（含创建家庭）、设备列表（点击设备回调 Base.devicePanelHandler
    跳转各 demo 自己的原生面板）、个人信息、退出登录。
    新工程只需 Podfile 加一行引用即可复用，无需重写。
    不含任何面板 / 小程序 / 配网业务包；扫码配网 / 小程序等由使用方按需集成。
  DESC
  s.homepage         = 'https://github.com/liuhepan-web/AppIOSBase'
  s.license          = { :type => 'MIT' }
  s.author           = { 'liuhepan' => 'liuhepan-web@users.noreply.github.com' }
  # 用 git 源，保证推到 git 后他人可下载复用（不是本地专属）。
  # 使用者在 Podfile 里用 :git 引用时会覆盖此处；本地 Demo 用 :path 引用时忽略此项。
  s.source           = { :git => 'https://github.com/liuhepan-web/AppIOSBase.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Classes/**/*.{swift}'

  # 本工程未全局 use_frameworks!，用静态 framework 形态产出 Swift 模块，
  # 使宿主 App 能 `import AppIOSBase`。
  s.static_framework = true

  # ============================================================================
  # 依赖（无任何面板 / 小程序 / 配网业务包）：
  # - ThingSmartHomeKit + ThingSmartBusinessExtensionKit：基础 SDK（账户 / 家庭）。
  # - ThingSmartBizCore：家庭切换后 updateConfig + 注册家庭协议。
  # - ThingModuleServices：ThingFamilyProtocol 定义（家庭协议）。
  # - ThingSmartDeviceKit：设备列表的设备模型与设备操作。
  # - 安全 SDK ThingSmartCryption：由宿主工程以 :path => './' 自行集成。
  # ============================================================================
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
  s.dependency 'ThingSmartBizCore'
  s.dependency 'ThingModuleServices'
  s.dependency 'ThingSmartDeviceKit'
end
