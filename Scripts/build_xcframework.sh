#!/usr/bin/env bash
# ============================================================================
# 把 AppIOSBase 源码 pod 打包成 XCFramework（device + simulator 双架构）。
# 这是 iOS 上「aar + Maven」的等价做法：只分发二进制，不暴露源码。
#
# 前置条件（在 Mac 上执行，沙箱内无法跑完整 archive）：
#   - Xcode（含命令行工具：xcodebuild）
#   - CocoaPods，且装好 cocoapods-gen 插件：  gem install cocoapods-gen
#
# 用法：
#   cd AppIOSBase
#   bash Scripts/build_xcframework.sh
#
# 产出：./AppIOSBase.xcframework
# ============================================================================
set -e

cd "$(dirname "$0")/.."
POD_NAME="AppIOSBase"
DERIVED="./build"

echo "==> 1) 用 pod gen 生成单 pod 工程（含源码与依赖）"
pod gen "$POD_NAME.podspec" --platforms=ios --use-modular-headers

WS="Gen/$POD_NAME/$POD_NAME.xcworkspace"
if [ ! -d "$WS" ]; then
  echo "ERROR: 未找到生成的 workspace: $WS（请确认已安装 cocoapods-gen）"
  exit 1
fi

echo "==> 2) archive device 架构 (generic/platform=iOS)"
xcodebuild archive \
  -workspace "$WS" \
  -scheme "$POD_NAME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$DERIVED/ios" \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "==> 3) archive 模拟器架构 (generic/platform=iOS Simulator)"
xcodebuild archive \
  -workspace "$WS" \
  -scheme "$POD_NAME" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath "$DERIVED/sim" \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "==> 4) 合成 XCFramework"
xcodebuild -create-xcframework \
  -framework "$DERIVED/ios.xcarchive/Products/Library/Frameworks/$POD_NAME.framework" \
  -framework "$DERIVED/sim.xcarchive/Products/Library/Frameworks/$POD_NAME.framework" \
  -output "$POD_NAME.xcframework"

echo "==> 完成：./$POD_NAME.xcframework"
echo "    下一步见 RELEASE_BINARY.md：推到私有 specs 仓库即可像 Maven 一样引用。"
