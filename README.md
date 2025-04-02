# TA-Lib Windows Wheels 构建项目

## 项目简介

本项目提供了一个 GitHub Actions 工作流程，用于在 Windows 平台上为不同的 Python 版本和架构（x86/AMD64）自动构建 [TA-Lib (Technical Analysis Library)](https://ta-lib.org/) 的 Python 轮子（wheels）。

TA-Lib 是一个广泛用于金融市场技术分析的库，但在 Windows 平台上安装原始的 `TA-Lib` Python 包通常比较困难，因为它需要预先编译 C 库。通过本项目构建的预编译轮子文件，用户可以直接通过 `pip` 安装，无需手动编译 C 库。

## 特性

- 为多个 Python 版本（3.7-3.12）构建轮子
- 同时支持 32 位（x86）和 64 位（AMD64）架构
- 使用最新的 TA-Lib C 库（版本 0.6.4）和 Python 绑定（版本 0.6.3）
- 通过 GitHub Actions 自动测试构建的轮子
- 轻松自定义构建参数（如版本、测试要求等）

## 工作流程

该项目使用 GitHub Actions 工作流程（`.github/workflows/build.yml`）来自动化构建过程。主要步骤包括：

1. 下载指定版本的 TA-Lib C 源代码和 Python 源代码
2. 使用 CMake 和 NMake 编译 TA-Lib C 库
3. 使用 cibuildwheel 为各种 Python 版本和架构构建轮子
4. 运行测试以确保轮子功能正常
5. 将构建好的轮子作为构建产物（artifacts）上传

## 使用方法

### 获取预构建的轮子

1. 前往本仓库的 [GitHub Actions](https://github.com/YOUR_USERNAME/YOUR_REPO/actions) 页面（请替换为你的实际仓库 URL）
2. 选择最近一次成功的 "Build TA-Lib wheels for Windows" 工作流程运行
3. 在运行详情页底部的 "Artifacts" 部分，下载对应你系统架构的轮子：
   - `wheels-win-amd64`：64 位 Windows 系统
   - `wheels-win32`：32 位 Windows 系统
4. 解压下载的 zip 文件，获取 `.whl` 文件

### 安装轮子

使用 pip 安装下载的轮子文件：

```bash
pip install path/to/downloaded/TA_Lib-x.y.z-cp3xx-cp3xx-win_xxx.whl
