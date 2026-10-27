import UIKit

/// 个人信息页（原生，无业务包依赖）：展示当前登录用户信息 + 退出登录。
/// 退出登录由 Base.logout 完成（内部清空本地状态并发出 `.baseDidLogout`），
/// App 层监听 `.baseDidLogout` 切回登录页。
final class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "个人信息"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let u = ThingSmartUser.sharedInstance()

        let rows: [(String, String)] = [
            ("用户名", u.userName ?? "-"),
            ("UID", "\(u.uid)"),
            ("邮箱", u.email ?? "-"),
            ("手机", u.phoneNumber ?? "-"),
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (key, value) in rows {
            let row = UIStackView()
            row.axis = .horizontal
            let k = UILabel()
            k.text = key
            k.textColor = .secondaryLabel
            k.setContentHuggingPriority(.required, for: .horizontal)
            let v = UILabel()
            v.text = value
            v.textAlignment = .right
            v.numberOfLines = 0
            row.addArrangedSubview(k)
            row.addArrangedSubview(v)
            stack.addArrangedSubview(row)
        }

        let logout = UIButton(type: .system)
        logout.setTitle("退出登录", for: .normal)
        logout.setTitleColor(.white, for: .normal)
        logout.backgroundColor = .systemRed
        logout.layer.cornerRadius = 10
        logout.addTarget(self, action: #selector(onLogoutTapped), for: .touchUpInside)
        stack.addArrangedSubview(logout)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logout.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    @objc private func onLogoutTapped() {
        let alert = UIAlertController(title: "退出登录",
                                      message: "确定要退出当前账号吗？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            Base.logout {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
}
