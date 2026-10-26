import UIKit

/// 注册页（Base 模块）。支持手机号 / 邮箱注册，含验证码。
/// 对应 Android 的注册能力。涂鸦注册需先发验证码再提交。国家码可点选。
class RegisterViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let segmented = UISegmentedControl(items: ["手机号", "邮箱"])
    private let card = UIView()

    private let countryField = CountryCodeField()
    private let accountRow = UIStackView()
    private let accountField = authTextField(placeholder: "请输入手机号", keyboard: .phonePad)
    private let codeRow = UIStackView()
    private let codeField = authTextField(placeholder: "请输入验证码", keyboard: .numberPad)
    private let sendCodeButton = outlineButton(title: "获取验证码")
    private let passwordField = authTextField(placeholder: "请设置密码（8-20 位）", isSecure: true)
    private let registerButton = primaryButton(title: "注 册")
    private let tipLabel = UILabel()

    private var isPhone: Bool { segmented.selectedSegmentIndex == 0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        view.backgroundColor = AuthTheme.accentEnd
        setupUI()
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
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

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

        // 国家码 + 账号 一行（邮箱模式隐藏国家码）
        accountRow.axis = .horizontal
        accountRow.spacing = 10
        accountRow.alignment = .fill
        accountRow.addArrangedSubview(countryField)
        accountRow.addArrangedSubview(accountField)
        cardStack.addArrangedSubview(accountRow)

        // 验证码 + 获取按钮 一行
        codeRow.axis = .horizontal
        codeRow.spacing = 10
        codeRow.alignment = .fill
        codeField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sendCodeButton.setContentHuggingPriority(.required, for: .horizontal)
        sendCodeButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        codeRow.addArrangedSubview(codeField)
        codeRow.addArrangedSubview(sendCodeButton)
        cardStack.addArrangedSubview(codeRow)

        cardStack.addArrangedSubview(passwordField)
        cardStack.addArrangedSubview(registerButton)
        contentStack.addArrangedSubview(card)

        tipLabel.textColor = .secondaryLabel
        tipLabel.font = .systemFont(ofSize: 12)
        tipLabel.numberOfLines = 0
        tipLabel.text = "注册需先获取验证码；手机号注册请选择国家码。"
        contentStack.addArrangedSubview(tipLabel)

        sendCodeButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(doRegister), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func segChanged() {
        let phone = isPhone
        countryField.isHidden = !phone
        accountField.placeholder = phone ? "请输入手机号" : "请输入邮箱"
        accountField.keyboardType = phone ? .phonePad : .emailAddress
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func sendCode() {
        let account = (accountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !account.isEmpty else {
            showAlert("请输入账号")
            return
        }
        let user = ThingSmartUser.sharedInstance()
        // type = 1 表示「注册」验证码（ThingSmartUser 7.8 用 NSInteger 类型码，无枚举类型）
        if isPhone {
            user.sendVerifyCode(withUserName: account, countryCode: countryField.selectedCode, type: 1,
                                success: { [weak self] in self?.showAlert("验证码已发送") },
                                failure: { [weak self] error in
                self?.showAlert("发送失败：\(error?.localizedDescription ?? "")") })
        } else {
            user.sendVerifyCode(withUserName: account, countryCode: "86", type: 1,
                                success: { [weak self] in self?.showAlert("验证码已发送") },
                                failure: { [weak self] error in
                self?.showAlert("发送失败：\(error?.localizedDescription ?? "")") })
        }
    }

    @objc private func doRegister() {
        let account = (accountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let code = (codeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text ?? ""
        guard !account.isEmpty, !code.isEmpty, !password.isEmpty else {
            showAlert("请填写账号、验证码和密码")
            return
        }
        let user = ThingSmartUser.sharedInstance()
        if isPhone {
            user.register(byPhone: countryField.selectedCode, phoneNumber: account, password: password, code: code,
                          success: { [weak self] in self?.onRegistered() },
                          failure: { [weak self] error in
                self?.showAlert("注册失败：\(error?.localizedDescription ?? "")") })
        } else {
            user.register(byEmail: "86", email: account, password: password, code: code,
                          success: { [weak self] in self?.onRegistered() },
                          failure: { [weak self] error in
                self?.showAlert("注册失败：\(error?.localizedDescription ?? "")") })
        }
    }

    private func onRegistered() {
        DispatchQueue.main.async {
            self.showAlert("注册成功，请登录")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
