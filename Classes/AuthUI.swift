import UIKit

/// 登录/注册通用视觉与控件工厂，统一品牌风格（取自 thing_custom_config.json 的 themeColor）。
enum AuthTheme {
    /// 主品牌色 #FF5A28
    static let accent = UIColor(hex: "#FF5A28") ?? UIColor(red: 1, green: 0.353, blue: 0.157, alpha: 1)
    /// 渐变末端 #FF8A5B
    static let accentEnd = UIColor(hex: "#FF8A5B") ?? accent
    /// 输入框浅底
    static let fieldBackground = UIColor(white: 0.97, alpha: 1)
}

extension UIColor {
    /// 支持 "#RRGGBB" 解析
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(red: CGFloat((v >> 16) & 0xff) / 255,
                  green: CGFloat((v >> 8) & 0xff) / 255,
                  blue: CGFloat(v & 0xff) / 255, alpha: 1)
    }
}

// MARK: - 国家码

struct CountryCode {
    let name: String
    let code: String
    var display: String { "+" + code }
}

extension CountryCode {
    /// 常用国家/地区码（含中国港澳台，按官方称谓）
    static let common: [CountryCode] = [
        CountryCode(name: "中国", code: "86"),
        CountryCode(name: "中国香港", code: "852"),
        CountryCode(name: "中国澳门", code: "853"),
        CountryCode(name: "中国台湾", code: "886"),
        CountryCode(name: "美国", code: "1"),
        CountryCode(name: "加拿大", code: "1"),
        CountryCode(name: "英国", code: "44"),
        CountryCode(name: "澳大利亚", code: "61"),
        CountryCode(name: "新西兰", code: "64"),
        CountryCode(name: "日本", code: "81"),
        CountryCode(name: "韩国", code: "82"),
        CountryCode(name: "新加坡", code: "65"),
        CountryCode(name: "马来西亚", code: "60"),
        CountryCode(name: "泰国", code: "66"),
        CountryCode(name: "越南", code: "84"),
        CountryCode(name: "印度尼西亚", code: "62"),
        CountryCode(name: "菲律宾", code: "63"),
        CountryCode(name: "印度", code: "91"),
        CountryCode(name: "德国", code: "49"),
        CountryCode(name: "法国", code: "33"),
        CountryCode(name: "意大利", code: "39"),
        CountryCode(name: "西班牙", code: "34"),
        CountryCode(name: "荷兰", code: "31"),
        CountryCode(name: "俄罗斯", code: "7"),
        CountryCode(name: "土耳其", code: "90"),
        CountryCode(name: "巴西", code: "55"),
        CountryCode(name: "墨西哥", code: "52"),
        CountryCode(name: "沙特阿拉伯", code: "966"),
        CountryCode(name: "阿联酋", code: "971")
    ]
}

/// 可点选的国家码输入框：点击弹出 UIPickerView，显示 "+86"。
final class CountryCodeField: UITextField {
    private let picker = UIPickerView()
    var codes: [CountryCode] = CountryCode.common
    private var selectedIndex = 0
    var selectedCode: String { codes[selectedIndex].code }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        borderStyle = .none
        text = codes[selectedIndex].display
        textAlignment = .center
        font = .systemFont(ofSize: 16, weight: .medium)
        tintColor = AuthTheme.accent
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        backgroundColor = AuthTheme.fieldBackground
        setContentHuggingPriority(.required, for: .horizontal)
        widthAnchor.constraint(equalToConstant: 84).isActive = true

        picker.dataSource = self
        picker.delegate = self
        inputView = picker

        let tb = UIToolbar()
        tb.sizeToFit()
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneTapped))
        tb.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), done], animated: false)
        inputAccessoryView = tb
    }

    @objc private func doneTapped() { resignFirstResponder() }

    /// 按码值选中（用于回填已保存的国家码）
    func select(code: String) {
        if let idx = codes.firstIndex(where: { $0.code == code }) {
            selectedIndex = idx
            picker.selectRow(idx, inComponent: 0, animated: false)
            text = codes[idx].display
        }
    }
}

extension CountryCodeField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { codes.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(codes[row].name)  +\(codes[row].code)"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        text = codes[row].display
    }
}

// MARK: - 控件工厂

/// 统一风格的输入框
func authTextField(placeholder: String, isSecure: Bool = false, keyboard: UIKeyboardType = .default) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.isSecureTextEntry = isSecure
    tf.keyboardType = keyboard
    tf.autocapitalizationType = .none
    tf.autocorrectionType = .no
    tf.borderStyle = .none
    tf.font = .systemFont(ofSize: 16)
    tf.textColor = .label
    tf.layer.cornerRadius = 10
    tf.layer.borderWidth = 1
    tf.layer.borderColor = UIColor.separator.cgColor
    tf.backgroundColor = AuthTheme.fieldBackground
    let pad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 8))
    tf.leftView = pad
    tf.leftViewMode = .always
    tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return tf
}

/// 统一风格的主按钮（品牌色实心）
func primaryButton(title: String) -> UIButton {
    let b = UIButton(type: .system)
    b.setTitle(title, for: .normal)
    b.setTitleColor(.white, for: .normal)
    b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    b.backgroundColor = AuthTheme.accent
    b.layer.cornerRadius = 12
    b.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return b
}

/// 统一风格的 secondary 按钮（描边）
func outlineButton(title: String) -> UIButton {
    let b = UIButton(type: .system)
    b.setTitle(title, for: .normal)
    b.setTitleColor(AuthTheme.accent, for: .normal)
    b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    b.backgroundColor = .clear
    b.layer.cornerRadius = 12
    b.layer.borderWidth = 1.5
    b.layer.borderColor = AuthTheme.accent.cgColor
    b.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return b
}
