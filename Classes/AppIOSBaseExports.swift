//
//  AppIOSBaseExports.swift
//  AppIOSBase
//
//  统一 re-export 本 pod 用到的涂鸦基础 SDK 模块，使 Base 内其它 Swift 文件
//  无需逐个 `import` 即可直接使用 ThingSmartUser 等类型。
//

// 仅 re-export 基础 SDK 模块（AppIOSBase 重构后只依赖这两个）。
// 业务包（设备面板 / 配网 / 家庭 等）由使用方在自己的工程引入，本库不再强制。
@_exported import ThingSmartHomeKit
@_exported import ThingSmartBusinessExtensionKit
