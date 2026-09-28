# WeiboMApp

**无广告微博轻享版** iOS 客户端

# 开发框架

https://github.com/kshipeng/MonkeyDev-Next

# Lookin iOS UI 调试软件

https://lookin.work/

# ZXHookUtil 工具库

https://github.com/SmileZXLee/ZXHookUtil

# 生成IPA

运行之后在源代码的LatestBuild目录双击createIPA.command即可生成IPA文件。

# 生成Tweak安装包

编译成功后，双击项目根目录的`createTweakPackages.command`，即可在`LatestBuild/TweakPackages`目录生成Release所需的全部文件：

- `WeiboMApp_{目标App版本}.v{Tweak版本}.ipa`（createIPA.command 生成的 Target.ipa 自动重命名）
- `{PACKAGE_ID}_{Tweak版本}_iphoneos-arm64_rootless.deb`（无根越狱）
- `{PACKAGE_ID}_{Tweak版本}_iphoneos-arm_rootful.deb`（有根越狱）
- `{PACKAGE_ID}_{Tweak版本}_iphoneos-arm_TrollStore.zip`（TrollStore 手动注入）

发布配置（包名、版本号、注入目标App的BundleId等）在脚本顶部修改。

# 编译出错处理

1. Multiple commands produce '/xxxx/Build/Products/Debug-iphoneos/WeiboMApp.app/Info.plist'

> 打开 **WeiboMApp** 目标的 `Build Phases`，从 `Copy Bundle Resources` 步骤中删除除`MDConfig.plist`和`extracted_entitlements.plist`两个文件之外的所有内容

2. unable to read input file '/xxx/WeiboMApp/WeiboMApp/tmp/extracted_entitlements.plist': No such file or directory (2)

> 再重新执行编译运行

# 参考项目

https://github.com/TouchFriend/BiliBiliMApp

https://github.com/andy-sheng/LookinServer-binary