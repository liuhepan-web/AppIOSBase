import UIKit

/// 登录页：对应 Android 的 DemoLoginActivity。
/// 支持手机号 / 邮箱 + 密码登录；底部提供「注册账号」入口进入 RegisterViewController。
final class LoginViewController: UIViewController {

    private let gradient = CAGradientLayer()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let logoBadge = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let segmented = UISegmentedControl(items: ["手机号", "邮箱"])
    private let card = UIView()

    private let countryField = CountryCodeField()
    private let accountRow = UIStackView()
    private let accountField = authTextField(placeholder: "请输入手机号", keyboard: .phonePad)
    private let passwordField = authTextField(placeholder: "请输入密码", isSecure: true)

    private let rememberSwitch = UISwitch()
    private let loginButton = primaryButton(title: "登 录")
    private let registerButton = outlineButton(title: "注册账号")

    private var isPhone: Bool { segmented.selectedSegmentIndex == 0 }
    private var autoLoginInFlight = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        view.backgroundColor = AuthTheme.accent
        setupUI()

        // 已登录直接进主页
        if ThingSmartUser.sharedInstance().isLogin == true {
            enterHub()
            return
        }

        // 预填已保存账号
        if DemoCurrentHomeStore.hasSavedLoginCredentials() {
            countryField.select(code: DemoCurrentHomeStore.getSavedCountry())
            accountField.text = DemoCurrentHomeStore.getSavedAccount()
            passwordField.text = DemoCurrentHomeStore.getSavedPassword()
            performLogin(fromAuto: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - UI

    private func setupGradient() {
        gradient.colors = [AuthTheme.accent.cgColor, AuthTheme.accentEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 36),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -36)
        ])

        // Logo
        logoBadge.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        logoBadge.layer.cornerRadius = 36
        logoBadge.translatesAutoresizingMaskIntoConstraints = false
        logoBadge.widthAnchor.constraint(equalToConstant: 72).isActive = true
        logoBadge.heightAnchor.constraint(equalToConstant: 72).isActive = true
        let logo = UIImageView(image: UIImage(systemName: "house.fill"))
        logo.tintColor = .white
        logo.contentMode = .center
        logo.translatesAutoresizingMaskIntoConstraints = false
        logoBadge.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: logoBadge.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: logoBadge.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 36),
            logo.heightAnchor.constraint(equalToConstant: 36)
        ])
        contentStack.addArrangedSubview(centered(logoBadge))

        // 标题
        titleLabel.text = "智能设备助手"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        subtitleLabel.text = "登录以管理你的智能设备"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.textAlignment = .center
        contentStack.addArrangedSubview(centered(titleLabel))
        contentStack.addArrangedSubview(centered(subtitleLabel))

        // 卡片
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 16
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 14
        cardStack.layoutMargins = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
        cardStack.isLayoutMarginsRelativeArrangement = true
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segChanged), for: .valueChanged)
        cardStack.addArrangedSubview(segmented)

        // 国家码 + 账号 一行
        accountRow.axis = .horizontal
        accountRow.spacing = 10
        accountRow.alignment = .fill
        accountRow.addArrangedSubview(countryField)
        accountRow.addArrangedSubview(accountField)
        cardStack.addArrangedSubview(accountRow)
        cardStack.addArrangedSubview(passwordField)

        let rememberRow = UIStackView(arrangedSubviews: [UILabel(text: "记住账号"), rememberSwitch])
        rememberRow.spacing = 8
        rememberRow.alignment = .center
        rememberRow.distribution = .equalSpacing
        cardStack.addArrangedSubview(rememberRow)
        cardStack.addArrangedSubview(loginButton)
        contentStack.addArrangedSubview(card)

        // 注册入口
        let tip = UILabel()
        tip.text = "还没有账号？"
        tip.textColor = .white
        tip.font = .systemFont(ofSize: 14)
        tip.textAlignment = .center
        contentStack.addArrangedSubview(centered(tip))
        contentStack.addArrangedSubview(registerButton)

        loginButton.addTarget(self, action: #selector(onLoginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(onRegisterTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func centered(_ v: UIView) -> UIView {
        let w = UIStackView(arrangedSubviews: [v])
        w.alignment = .center
        return w
    }

    // MARK: - 事件

    @objc private func segChanged() {
        let phone = isPhone
        accountField.placeholder = phone ? "请输入手机号" : "请输入邮箱"
        accountField.keyboardType = phone ? .phonePad : .emailAddress
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func onLoginTapped() { performLogin(fromAuto: false) }

    @objc private func onRegisterTapped() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func performLogin(fromAuto: Bool) {
        let country = countryField.selectedCode
        let account = (accountField.text ?? "").trimmingCharacters(in: .whitespaces)
        let password = (passwordField.text ?? "").trimmingCharacters(in: .whitespaces)

        guard !account.isEmpty, !password.isEmpty else {
            if !fromAuto { showAlert("账号或密码不能为空") }
            return
        }
        guard !autoLoginInFlight else { return }
        autoLoginInFlight = true
        setUI(enabled: false)
        if fromAuto { showAlert("正在自动登录…", title: "") }

        let success: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.autoLoginInFlight = false
            self.setUI(enabled: true)
            if self.rememberSwitch.isOn {
                DemoCurrentHomeStore.saveLoginCredentials(country: country, account: account, password: password)
            } else {
                DemoCurrentHomeStore.clearLoginCredentials()
            }
            // 登录成功后务必刷新业务包缓存
            ThingSmartBizCore.sharedInstance().updateConfig()
            self.enterHub()
        }
        let failure: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }
            self.autoLoginInFlight = false
            self.setUI(enabled: true)
            if !fromAuto {
                self.showAlert("登录失败：\(error?.localizedDescription ?? "未知错误")")
            }
        }

        let user = ThingSmartUser.sharedInstance()
        if isPhone {
            user.login(byPhone: country, phoneNumber: account, password: password, success: success, failure: failure)
        } else {
            // 邮箱登录同样需要国家码（后端会校验 countryCode 非空）
            user.login(byEmail: country, email: account, password: password, success: success, failure: failure)
        }
    }

    private func setUI(enabled: Bool) {
        loginButton.isEnabled = enabled
        countryField.isEnabled = enabled
        accountField.isEnabled = enabled
        passwordField.isEnabled = enabled
    }

    /// 登录成功后通知 App 层切换到 Features 主页（通知解耦，Base 不反向依赖 Features / App）。
    private func enterHub() {
        NotificationCenter.default.post(name: .baseDidLogin, object: nil)
    }
}

private extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
