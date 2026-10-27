import UIKit
import ThingSmartDeviceKit

/// 设备列表页：对应 Android 的 DemoDeviceListActivity。
/// 列出当前家庭下的设备（获取设备列表 / 侧滑移除设备）。
/// 点击设备 → 跳转「原生设备面板」：面板由各 demo 自己实现，启动时通过
/// `Base.devicePanelHandler` 注册跳转逻辑（不用面板业务包）；
/// 未注册时仅展示设备信息。
/// 所需依赖：ThingSmartDeviceKit（设备模型 / 设备操作），已在 podspec 中声明。
final class DeviceListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var devices: [ThingSmartDeviceModel] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设备列表"
        view.backgroundColor = .systemBackground
        setupUI()

        let homeId = DemoCurrentHomeStore.currentHomeId
        guard homeId != 0 else {
            showAlert("请先在首页选择一个家庭")
            return
        }
        loadDevices(homeId: homeId)
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "devcell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadDevices(homeId: Int64) {
        let home = ThingSmartHome(homeId: homeId)
        home?.getDataWithSuccess({ [weak self] _ in
            self?.devices = home?.deviceList ?? []
            self?.tableView.reloadData()
        }, failure: { error in
            print("getHomeData error: \(error?.localizedDescription ?? "")")
        })
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "devcell", for: indexPath)
        let d = devices[indexPath.row]
        cell.textLabel?.text = d.name ?? d.devId
        cell.detailTextLabel?.text = d.devId
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let d = devices[indexPath.row]
        if let handler = Base.devicePanelHandler {
            // 跳转各 demo 自己的原生面板
            handler(d, navigationController)
        } else {
            showAlert("设备信息\n名称：\(d.name ?? "-")\n设备 ID：\(d.devId ?? "-")\n\n提示：尚未注册原生面板，请在 App 启动时设置 Base.devicePanelHandler")
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "移除") { [weak self] _, _, done in
            self?.removeDevice(at: indexPath)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - 移除设备

    private func removeDevice(at indexPath: IndexPath) {
        guard let devId = devices[indexPath.row].devId,
              let device = ThingSmartDevice(deviceId: devId) else { return }
        device.remove({ [weak self] in
            self?.devices.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }, failure: { [weak self] error in
            self?.showAlert("移除设备失败：\(error?.localizedDescription ?? "未知错误")")
        })
    }
}
