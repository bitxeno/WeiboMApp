# WeiboMApp

**无广告微博轻享版** iOS 客户端

# ZXHookUtil 工具库

https://github.com/SmileZXLee/ZXHookUtil

# 编译出错处理

1. Multiple commands produce '/xxxx/Build/Products/Debug-iphoneos/WeiboMApp.app/Info.plist'

> 打开 **WeiboMApp** 目标的 `Build Phases`，从 `Copy Bundle Resources` 步骤中删除除`MDConfig.plist`和`extracted_entitlements.plist`两个文件之外的所有内容

2. unable to read input file '/xxx/WeiboMApp/WeiboMApp/tmp/extracted_entitlements.plist': No such file or directory (2)

> 再重新执行编译运行

# 参考项目

https://github.com/TouchFriend/BiliBiliMApp

https://github.com/andy-sheng/LookinServer-binary