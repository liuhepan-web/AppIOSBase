# AppIOSBase 二进制发布（类 Android aar + Maven）

目标：像 Android 把模块打成 `aar` 再发到 `Maven` 仓库那样，把 `AppIOSBase` 打成
**XCFramework** 再发到**私有 CocoaPods specs 仓库**。使用者只需一行 `pod 'AppIOSBase'`
即可引用，拿不到源码、也不需要 `:git`。

## 一、产出 XCFramework
在 Mac 上执行（沙箱内无法跑完整 archive）：

```bash
cd AppIOSBase
bash Scripts/build_xcframework.sh
# 产出 ./AppIOSBase.xcframework
```

脚本会：
1. `pod gen` 生成单 pod 工程（需 `gem install cocoapods-gen`）；
2. 分别 archive device / simulator 两种架构；
3. `xcodebuild -create-xcframework` 合成 `AppIOSBase.xcframework`。

## 二、把二进制存到可下载的位置
二选一（等价 Maven 的 artifact 存储）：
- **A. 跟随 git 仓库**：把 `AppIOSBase.xcframework` 提交进 `AppIOSBase` 仓库并打 tag
  （最简单，xcframework 体积较大但胜在零额外设施）。
- **B. 对象存储 / Artifactory**：上传 xcframework，podspec 的 `s.source` 改为
  `{ :http => 'https://your-cdn/AppIOSBase-0.2.0.xcframework.zip' }`，并去掉 `:git`。

本文以 A 为例。

## 三、建私有 specs 仓库（等价 Maven 私服）
```bash
# 在 Git 上新建一个空仓库，例如 your-org/ios-specs
pod repo add mini-specs git@github.com:your-org/ios-specs.git
```

## 四、放二进制 podspec 并发布
```bash
# 把模板改名放进 specs 仓库对应版本目录
mkdir -p ~/.cocoapods/repos/mini-specs/AppIOSBase/0.2.0
cp AppIOSBase.binary.podspec ~/.cocoapods/repos/mini-specs/AppIOSBase/0.2.0/AppIOSBase.podspec
# 记得把 podspec 里 YOUR_NAME 换成真实用户名；若用方案 B 改 s.source

cd ~/.cocoapods/repos/mini-specs
git add . && git commit -m "Add AppIOSBase 0.2.0 (binary)" && git push
```

## 五、使用者引用（最终效果，一行搞定）
使用者 Podfile 顶部加私有源，然后正常 `pod`：
```ruby
source 'https://github.com/your-org/ios-specs.git'   # 你的私有 specs
source 'https://github.com/tuya/tuya-pod-specs.git'
source 'https://cdn.cocoapods.org/'

target 'NewDemo' do
  # ... 涂鸦基础/业务包依赖 ...
  pod 'AppIOSBase', '0.2.0'   # 不再需要 :git，也不拿源码
end
```
执行 `pod install` 即用。

## 对比：源码 pod vs 二进制 pod
| 方式 | Podfile 引用 | 是否需要推仓库 | 是否暴露源码 | 适用 |
|------|--------------|----------------|--------------|------|
| 源码 pod（AppIOSBase.podspec） | `pod 'AppIOSBase', :git => '...'` | 是（已就绪） | 是 | 内部多 demo 快速复用 ✅ |
| 二进制 pod（AppIOSBase.binary.podspec） | `pod 'AppIOSBase', '0.2.0'` | 是 + 私有 specs | 否 | 对外发布 / 闭源 SDK |
