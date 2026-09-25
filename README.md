<img align="right" src="assets/icons/app_icon.svg" width="180"/>

# 媒体格式转换器
MrXiaoM's FFmpeg UI.

桌面端媒体格式转换器，套壳本地 `ffmpeg` / `ffprobe`。类 Fluent 深色界面风格，设计为容易上手的经典任务队列布局。支持 Windows、Linux 和 macOS。

> [!WARNING]
>
> 本项目包含大量 AI 生成代码，介意勿用。
>
> 由于作者没有良好的测试环境，Linux 和 macOS 仅作最低支持，欢迎提交 PR 对 Linux 和 macOS 进行兼容。

## 运行

剪辑页用 `media_kit` 做实时预览：打开剪辑时才初始化播放器，关闭后释放。Linux 需要系统 `libmpv`，没有时预览会失败，但不影响裁剪。

```shell
flutter pub get
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

首次使用前，请确保本机有安装 `ffmpeg`，你可以到 [FFmpeg 官网](https://ffmpeg.org/download.html) 自行下载各种发行版。软件会按以下顺序探测：

1. 设置中指定的路径
2. 当前目录 / 程序目录下的 `ffmpeg/`
3. 系统 PATH
4. Windows：`Program Files` 与 `Program Files (x86)` 中带 ffmpeg 的目录
5. macOS：Homebrew、`/usr/local/bin`、`/opt/local/bin`
6. Linux：`/usr/bin`、`/usr/local/bin`、`~/.local/bin`、snap

也可以在 **文件 -> 设置** 里手动指定。
