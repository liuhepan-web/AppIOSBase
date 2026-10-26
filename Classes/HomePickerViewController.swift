import UIKit

/// 家庭选择 / 创建页：对应 Android 的 DemoHomePickerActivity。
/// 列出当前账号下的家庭，支持创建家庭，点选后写入本地「当前家庭」。
final class HomePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var homes: [ThingSmartHomeModel] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择家庭"
        view.backgroundColor = .systemBackground
        setupUI()
        loadHomes()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let createButton = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(onCreateTapped))
        navigationItem.rightBarButtonItem = createButton
    }

    private func loadHomes() {
        let manager = ThingSmartHomeManager()
        manager.getHomeList(success: { [weak self] homes in
            self?.homes = homes ?? []
            self?.tableView.reloadData()
        }, failure: { error in
            print("getHomeList error: \(error?.localizedDescription ?? "")")
        })
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let home = homes[indexPath.row]
        cell.textLabel?.text = home.name ?? "(未命名家庭)"
        cell.detailTextLabel?.text = "homeId=\(home.homeId)"
        cell.accessoryType = home.homeId == DemoCurrentHomeStore.currentHomeId ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let home = homes[indexPath.row]
        DemoCurrentHomeStore.currentHomeId = home.homeId
        // 通知业务包当前家庭已切换，刷新缓存
        ThingSmartBizCore.sharedInstance().updateConfig()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - 创建家庭

    @objc private func onCreateTapped() {
        let alert = UIAlertController(title: "创建家庭", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "家庭名称" }
        alert.addTextField { tf in
            tf.placeholder = "城市"
            tf.text = "杭州"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "创建", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
            let city = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
            guard !name.isEmpty else {
                self.showAlert("家庭名称不能为空")
                return
            }
            self.createHome(name: name, city: city)
        })
        present(alert, animated: true)
    }

    private func createHome(name: String, city: String) {
        let manager = ThingSmartHomeManager()
        manager.addHome(withName: name, geoName: city, rooms: [], latitude: 0, longitude: 0, success: { [weak self] _ in
            self?.loadHomes()
        }, failure: { [weak self] error in
            self?.showAlert("创建家庭失败：\(error?.localizedDescription ?? "未知错误")")
        })
    }
}
