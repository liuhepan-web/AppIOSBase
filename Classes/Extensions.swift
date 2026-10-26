import UIKit
import ObjectiveC

extension UIViewController {

    /// 简单的提示弹窗
    public func showAlert(_ message: String, title: String = "提示") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// 让 UIButton 直接绑定闭包，简化「打开小程序」等按钮的事件绑定
private var ButtonActionKey: UInt8 = 0

extension UIButton {

    public func setAction(_ closure: @escaping () -> Void) {
        objc_setAssociatedObject(self, &ButtonActionKey, closure, .OBJC_ASSOCIATION_RETAIN)
        addTarget(self, action: #selector(_runAction), for: .touchUpInside)
    }

    @objc private func _runAction() {
        (objc_getAssociatedObject(self, &ButtonActionKey) as? () -> Void)?()
    }
}
