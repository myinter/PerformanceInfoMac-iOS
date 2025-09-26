# PerformanceInfo.swift

iOS / macOS 高性能监控套件
High-Performance Monitoring Suite for iOS & macOS

---

## 🌟 功能亮点 / Features

`PerformanceInfo.swift` 是一套完整的 iOS/macOS 性能监控解决方案，提供设备、CPU、内存、电池等全方位性能数据。
This is a complete iOS/macOS performance monitoring solution that provides comprehensive data on device, CPU, memory, and battery.

**Key Features / 主要功能:**

* **设备信息识别 / Device Info**：iPhone, Mac, 模拟器 / iPhone, Mac, Simulator
* **CPU 型号与类型 / CPU Info**：支持 Apple A 系列、M 系列、Intel x86/x64 / Supports Apple A/M series, Intel x86/x64
* **CPU 核心数量 / CPU Count**
* **内存信息 / Memory Info**：总内存、可用内存、空闲内存 / Total, available, free memory
* **进程资源使用 / Process Resource**：进程内存、进程 CPU 占用 / Process memory and CPU usage
* **CPU 占用率 / CPU Usage**：每线程、每核心、进程总占用、设备总占用 / Per-thread, per-core, process-level, device-level
* **电池状态 / Battery Level**：iOS/macOS
* **应用启动时间 / App Startup Time**
* **性能等级评估 / Performance Level**：低/中/高 / Low/Medium/High

---

## 📦 安装 / Installation

将 `PerformanceInfo.swift` 文件直接添加到你的 iOS/macOS 项目中，无需额外依赖。
Add `PerformanceInfo.swift` directly to your iOS/macOS project. No dependencies required.

```swift
import PerformanceInfo
```

---

## 🛠️ API 模块说明 / API Modules

### 1️⃣ 设备与 CPU / Device & CPU

| API         | 类型 / Type  | 描述 / Description                                      |
| ----------- | ---------- | ----------------------------------------------------- |
| `DEV_type`  | `DEV_TYPE` | 获取设备类型 / Device type (iPhone, Mac, Simulator)         |
| `CPU_type`  | `CPU_TYPE` | CPU 型号类型 / CPU type (Apple A/M series, Intel x86/x64) |
| `CPUModel`  | `String`   | CPU 型号字符串 / CPU model string                          |
| `numOfCPUs` | `UInt32`   | CPU 核心数量 / Number of CPU cores                        |

---

### 2️⃣ 内存信息 / Memory

| API                           | 类型 / Type | 描述 / Description                                  |
| ----------------------------- | --------- | ------------------------------------------------- |
| `totalMemoryMB`               | `UInt64`  | 总内存（MB） / Total memory in MB                      |
| `totalMemory`                 | `UInt64`  | 总内存（字节） / Total memory in bytes                   |
| `availableMemorySize()`       | `Float`   | 可用内存（MB） / Available memory in MB                 |
| `freeMemorySize()`            | `Float`   | 空闲内存（MB） / Free memory in MB                      |
| `currentProcessMemoryUsage()` | `Float`   | 当前进程内存占用（MB） / Current process memory usage in MB |

---

### 3️⃣ CPU 使用率 / CPU Usage

| API                        | 类型 / Type            | 描述 / Description                                            |
| -------------------------- | -------------------- | ----------------------------------------------------------- |
| `cpuUsageForEveryThread()` | `[thread_t: Float]?` | 当前进程每个线程 CPU 占用率 / Per-thread CPU usage for current process |
| `processLevelCPUusage()`   | `Float`              | 当前进程总 CPU 占用率 / Total CPU usage for current process         |
| `occupationForEveryCPU()`  | `[Float]?`           | 每个 CPU 核心占用率 / Per-core CPU usage                           |
| `deviceLevelCPUusage()`    | `Float`              | 设备整体 CPU 占用率 / Total CPU usage for device                   |

---

### 4️⃣ 电池信息 / Battery

| API            | 类型 / Type | 描述 / Description                            |
| -------------- | --------- | ------------------------------------------- |
| `batteryLevel` | `Float`   | 电池电量（0.0 ~ 1.0） / Battery level (0.0 ~ 1.0) |

---

### 5️⃣ 性能等级 / Performance Level

| API                | 类型 / Type          | 描述 / Description                                                     |
| ------------------ | ------------------ | -------------------------------------------------------------------- |
| `performanceLevel` | `PerformanceLevel` | 设备/进程性能等级评估 / Device/Process performance level (Low / Medium / High) |

---

### 6️⃣ 应用启动时间 / App Startup Time

| API                     | 类型 / Type      | 描述 / Description                                                           |
| ----------------------- | -------------- | -------------------------------------------------------------------------- |
| `processStartTimestamp` | `TimeInterval` | 当前进程创建时间 / Process creation timestamp (used to calculate App startup time) |

---

## 🚀 使用示例 / Usage Example

```swift
import Foundation

// 设备信息 / Device Info
let deviceType = PerformanceInfo.DEV_type
let cpuType = PerformanceInfo.CPU_type
print("Device: \(deviceType), CPU: \(cpuType)")

// 内存信息 / Memory Info
let totalMem = PerformanceInfo.totalMemoryMB
let availMem = PerformanceInfo.availableMemorySize()
print("Total Memory: \(totalMem) MB, Available: \(availMem) MB")

// CPU 占用 / CPU Usage
let processCPU = PerformanceInfo.processLevelCPUusage()
let deviceCPU = PerformanceInfo.deviceLevelCPUusage()
print("Process CPU: \(processCPU)%, Device CPU: \(deviceCPU)%")

// 电池 / Battery
let battery = PerformanceInfo.batteryLevel
print("Battery: \(battery * 100)%")

// 每线程 CPU 占用 / Per-thread CPU usage
if let threadCPU = PerformanceInfo.cpuUsageForEveryThread() {
    for (thread, usage) in threadCPU {
        print("Thread \(thread): \(usage)%")
    }
}

// 性能等级 / Performance Level
let perfLevel = PerformanceInfo.performanceLevel
print("Performance Level: \(perfLevel)")

// 发热状况 / ThermalState of current device
let thermalState = PerformanceInfo.thermalState
print("CPU thermalState \(thermalState)" )

```

---

## 💡 为什么选择 PerformanceInfo.swift / Why Choose PerformanceInfo.swift

* ✅ **主流方案 / Industry Standard**：参考并兼容大厂 iOS/macOS 性能监控标准 / Adopted in major companies projects
* ✅ **全平台支持 / Cross-Platform**：iOS, macOS, 模拟器 / iOS, macOS, Simulator
* ✅ **高精度数据 / High-Precision Data**：CPU、内存、进程、线程级别资源占用 / CPU, memory, process, thread-level metrics
* ✅ **轻量级实现 / Lightweight**：单文件，无第三方依赖 / Single file, no third-party dependency

---

## 📜 许可证 / License

MIT License
详见 LICENSE 文件 / See LICENSE file
