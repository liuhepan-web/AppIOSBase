Pod::Spec.new do |s|
  s.name             = 'AppIOSBase'
  s.version          = '0.2.0'
  s.summary          = '涂鸦 App 基础能力库：SDK 初始化 / 注册 / 登录 / 登录态'
  s.description      = <<-DESC
    AppIOSBase 把最基础的「账户」能力（SDK 初始化、注册、登录、登录态与当前家庭存储）
    收敛为自包含模块。新工程只需 Podfile 加一行引用即可复用，无需重写。
    设备列表 / 家庭选择 / 配网 / 设备面板等业务包界面不在本库，由使用方按需集成业务包后自行实现。
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
  # 依赖：仅基础 SDK（重构后 AppIOSBase 只做 登录/注册/SDK初始化/登录态）
  # - 基础 SDK（必带）：ThingSmartHomeKit（账户/家庭/设备等核心 API）+ BusinessExtensionKit。
  # - 安全 SDK ThingSmartCryption：由各宿主工程以 :path => './' 自行集成，不写进 podspec。
  # - 业务包（设备面板 / 配网 / 小程序 / 家庭 等）：本库不再包含相关界面，
  #   由使用方在自己的 Podfile 里【按需】添加，没有需要就不添加。
  # ============================================================================
  s.dependency 'ThingSmartHomeKit', '~> 7.8.0'
  s.dependency 'ThingSmartBusinessExtensionKit', '~> 7.8.0'
end
