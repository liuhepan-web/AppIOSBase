Pod::Spec.new do |s|
  s.name             = 'AppIOSBase'
  s.version          = '0.2.0'
  s.summary          = '涂鸦 App 基础能力库：SDK 初始化 / 注册 / 登录 / 设备列表'
  s.description      = <<-DESC
    AppIOSBase 把基础能力（SDK 初始化、注册、登录、登录态存储、设备列表）收敛为自包含模块。
    新工程只需 Podfile 加一行引用即可复用，无需重写。
    家庭选择 / 配网 / 小程序等界面不在本库，由使用方按需集成业务包后自行实现。
  DESC
  s.homepage         = 'https://github.com/liuhepan-web/AppIOSBase'
  s.license          = { :type => 'MIT' }
  s.author           = { 'liuhepan' => 'liuhepan-web@users.noreply.github.com' }
  # 用 git 源，保证推到 git 后他人可下载复用（不是本地专属）。
  # 使用者在 Podfile 里用 :git => '你的仓库地址' 引用时会覆盖此处；本地 Demo 用 :path 引用时忽略此项。
  s.source           = { :git => 'https://github.com/liuhepan-web/AppIOSBase.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Classes/**/*.{swift}'

  # 本工程未全局 use_frameworks!，用静态 framework 形态产出 Swift 模块，
  # 使宿主 App 能 `import AppIOSBase`。
  s.static_framework = true

  # ============================================================================
  # 依赖分层：
  # - 基础 SDK（必带）：ThingSmartHomeKit（账户/家庭核心 API）+ BusinessExtensionKit。
  # - 设备列表界面所需（Base.makeDeviceListViewController）：BizCore（服务查找）+
  #   ModuleServices（ThingPanelProtocol 定义处）+ DeviceKit（设备模型/设备操作）+
  #   PanelBizBundle（运行时提供面板实现）。
  # - 安全 SDK ThingSmartCryption：由宿主工程以 :path => './' 自行集成，不写进 podspec。
  # - 其他业务包（配网 / 小程序 / 家庭 / 媒体 等）：本库未用到，由使用方【按需】添加。
  # ============================================================================
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
  s.dependency 'ThingSmartBizCore'
  s.dependency 'ThingModuleServices'
  s.dependency 'ThingSmartDeviceKit'
  s.dependency 'ThingSmartPanelBizBundle', '~> 7.8.0'
end
