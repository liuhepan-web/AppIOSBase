import UIKit

/// 配网（设备激活）页，Base 模块。
/// 使用 ThingSmartActivator 的 EZ（快连）模式把设备连上当前家庭所属 Wi-Fi。
///
/// 注意：配网 API 各 SDK 版本命名略有差异：
/// - 模式枚举可能是 `ThingSmartActivatorMode.ez` 或 `ThingSmartActivatorModeEZ`；
/// - 取 token 方法可能是 `getTokenWithHomeId` / `getToken(withHomeId:)`。
/// 若编译报“无此方法/类型”，按你安装的 `ThingSmartHomeKit` 版本微调即可。
class PairingViewController: UIViewController, ThingSmartActivatorDelegate {

    private var homeId: Int64 = Base.currentHomeId

    private let homeLabel = UILabel()
    private let ssidField = UITextField()
    private let passwordField = UITextField()
    private let modeSegment = UISegmentedControl(items: ["EZ 快连", "AP 热点"])
    private let startButton = UIButton(type: .system)
    private let tipLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "配网"
        view.backgroundColor = .systemBackground
        setupUI()
        refreshHome()
    }

    private func setupUI() {
        homeLabel.font = .systemFont(ofSize: 14)
        homeLabel.textColor = .secondaryLabel

        ssidField.placeholder = "Wi-Fi 名称 (SSID)"
        ssidField.borderStyle = .roundedRect

        passwordField.placeholder = "Wi-Fi 密码"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true

        modeSegment.selectedSegmentIndex = 0

        startButton.setTitle("开始配网", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startPairing), for: .touchUpInside)

        tipLabel.textColor = .secondaryLabel
        tipLabel.font = .systemFont(ofSize: 12)
        tipLabel.numberOfLines = 0
        tipLabel.text = "需先选择一个家庭。设备指示灯快闪时选 EZ；慢闪时选 AP。"

        let stack = UIStackView(arrangedSubviews: [homeLabel, ssidField, passwordField,
                                                   modeSegment, startButton, tipLabel])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshHome() {
        if homeId > 0 {
            homeLabel.text = "当前家庭 ID：\(homeId)"
        } else {
            homeLabel.text = "⚠️ 未选择家庭，请先返回首页选择一个家庭"
        }
    }

    @objc private func startPairing() {
        guard homeId > 0 else {
            showAlert("请先选择一个家庭")
            return
        }
        guard let ssid = ssidField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !ssid.isEmpty else {
            showAlert("请输入 Wi-Fi 名称")
            return
        }
        let password = passwordField.text ?? ""

        let activator = ThingSmartActivator()
        activator.delegate = self
        activator.getTokenWithHomeId(homeId, success: { [weak self] token in
            let mode: ThingActivatorMode = (self?.modeSegment.selectedSegmentIndex == 1) ? .AP : .EZ
            activator.startConfigWiFi(mode, ssid: ssid, password: password, token: token ?? "", timeout: 100)
        }, failure: { [weak self] error in
            self?.showAlert("获取配网 token 失败：\(error?.localizedDescription ?? "")")
        })
    }

    // MARK: - ThingSmartActivatorDelegate
    func activator(_ activator: ThingSmartActivator, didReceiveDevice deviceModel: ThingSmartDeviceModel?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let device = deviceModel {
                self?.showAlert("配网成功：\(device.name ?? "未知设备")")
            } else if let err = error {
                self?.showAlert("配网失败：\(err.localizedDescription)")
            }
        }
    }
}
