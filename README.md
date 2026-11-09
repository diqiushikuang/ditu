# Language Conqueror — Android MVP 1.0

用语言解锁世界的游戏化语言学习 App。当前版本是可持续迭代的 Android MVP。

## 当前功能

- 首页：等级、经验值、词汇数量、挑战次数
- 学习：5 道英语基础词汇选择题，完成后获得 XP 和词汇进度
- 世界：示意世界地图与区域解锁进度
- 我的：出生地、目标语言设置、进度重置
- 本地持久化：使用 `shared_preferences`
- GitHub Actions：推送代码后自动构建 Release APK

## 自动打包

1. 在 GitHub 新建一个空仓库，例如 `language-conqueror`。
2. 将本项目所有文件上传到仓库根目录。
3. 确认默认分支为 `main`（或 `master`）。
4. 打开仓库的 **Actions** 页面，允许 GitHub Actions 运行。
5. 每次 push 到 `main`/`master` 都会触发 Android APK 构建。
6. 构建完成后进入对应 workflow run，在 **Artifacts** 下载 `language-conqueror-android-apk`。

也可以在 Actions 中手动运行 **Build Android APK**。

## 本地运行（需要安装 Flutter SDK）

```bash
flutter create --platforms=android --org com.languageconqueror --project-name language_conqueror build_app
rm -rf build_app/lib
cp -R lib build_app/lib
cp pubspec.yaml build_app/pubspec.yaml
cd build_app
flutter pub get
flutter run
```

## 当前版本边界

- 地图是游戏化示意地图，不是精确地理边界地图。
- 当前词汇题库为内置演示数据，只有英语基础词汇。
- 区域解锁阈值是 MVP 游戏规则，不代表真实语言能力或 CEFR 认证。
- 出生地和学习语言保存在本机；卸载 App 后本地进度可能丢失。
- 尚未接入账号、云同步、在线题库、语音识别或排行榜。

## 下一步建议

1. 增加可扩充的词库与错题复习。
2. 用可靠的地理数据替换示意地图。
3. 建立词汇、听力、阅读、口语的综合能力评估。
4. 加入云端账号与多设备同步。
