//
//  PerformanceInfo.swift
//  
//
//  Created by 熊韦华 on 2021/9/18.
//

/*
PerformanceInfo.swift
iOS / macOS Performance Monitoring Suite

Copyright (c) 2021-2025 熊韦华 (Kuma Osa)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.
2. The Software is provided "as is", without warranty of any kind, express or
   implied, including but not limited to the warranties of merchantability,
   fitness for a particular purpose, and non-infringement.

---

PerformanceInfo.swift
iOS / macOS 性能监控套件

版权所有 (c) 2021-2025 熊韦华

特此免费授予任何获得本软件及相关文档的人士无限制使用本软件的权利，包括但不限于使用、复制、修改、合并、发布、分发、再授权及/或销售软件的副本，并允许向其提供软件的人如此操作，条件如下：

1. 必须在软件的所有副本或主要部分中包含上述版权声明及本许可声明。
2. 本软件按“原样”提供，不提供任何形式的保证，包括但不限于对适销性、特定用途适用性及非侵权性的保证。
 */

import Foundation

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import IOKit
import IOKit.ps
#endif

public enum DeviceThermalState: Int {
    case nominal        // 正常
    case fair           // 轻微高温
    case serious        // 严重高温
    case critical       // 临界高温
    case unknown        // 未知或不支持
}

public enum DEV_TYPE: Int {
    case IPHONE
    case APPLE_SILICON_MAC
    case INTEL_MAC
    case ARM_SIMULATOR
    case INTEL_SIMULATOR
}

// An enumeration type used to distinguish the performance levels of processors.
public enum CPU_TYPE: Int {
    
    case UNKNOWN = 0
    // Intel x86 Macs/iOS simulators
    case INTEL_X86
    case INTEL_X64

    case X64_SIMULATOR
    case I386_SIMULATOR
    case LowerThanA4
    case A4_APPLE
    case A5_APPLE
    case A6_APPLE
    case A5X_A6X_APPLE
    case A7_APPLE
    case A8_APPLE
    case A8X_APPLE
    case A9_APPLE
    case A9X_APPLE
    case A10_APPLE
    case A10_A10X_APPLE
    case UpperThanA10
    case A11_APPLE
    case A12_APPLE
    case A12X_APPLE
    case UpperThanA12
    case A11X_A12_APPLE
    case A13_APPLE
    case UpperThanA14
    case A14_APPLE
    case A15_APPLE
    case UpperThanA15
    case A16_APPLE
    case A17_APPLE
    case A18_APPLE
    case A18_PRO_APPLE
    case A19_APPLE
    case A19_PRO_APPLE
    case UpperThanA19

    // Apple Silicon Mac / iPad Pro
    case M1_APPLE
    case M1_PRO_APPLE
    case M1_MAX_APPLE
    case M1_ULTRA_APPLE
    case M2_APPLE
    case M2_PRO_APPLE
    case M2_MAX_APPLE
    case M2_ULTRA_APPLE
    case M3_APPLE
    case M3_PRO_APPLE
    case M3_MAX_APPLE
    case M3_ULTRA_APPLE
    case M4_APPLE
    case M4_PRO_APPLE
    case M4_MAX_APPLE
    case M4_ULTRA_APPLE
    case UpperThanM4

}

public enum PerformanceLevel: Int {
    case lowPerf
    case midPerf
    case highPerf
}

public class PerformanceInfo {
    
    /// 获取当前设备热管理状态  / thermalState of current device
    public static var thermalState: DeviceThermalState {
        #if os(iOS) || os(tvOS) || os(watchOS)
        // iOS / tvOS / watchOS
        let state = UIDevice.current.thermalState
        switch state {
            case .nominal: return .nominal
            case .fair: return .fair
            case .serious: return .serious
            case .critical: return .critical
            default: return .unknown
        }
        #elseif os(macOS)
        // macOS
        return .unknown
        #else
        return .unknown
        #endif
    }

    // Return the current battery level of the device.
    // If it is a device without a battery, return nil.
    public static var batteryLevel: Float? {
        #if os(iOS)
        let device = UIDevice.current
        if !device.isBatteryMonitoringEnabled {
            device.isBatteryMonitoringEnabled = true
        }
        let level = device.batteryLevel
        #if DEBUG
        debugPrint("iOS battery level: \(level)")
        #endif
        return level >= 0 ? level : nil

        #elseif os(macOS)
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty else {
            return nil
        }

        for ps in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, ps)?.takeUnretainedValue() as? [String: Any],
               let currentCapacity = info[kIOPSCurrentCapacityKey as String] as? Int,
               let maxCapacity = info[kIOPSMaxCapacityKey as String] as? Int,
               maxCapacity > 0 {
                let level = Float(currentCapacity) / Float(maxCapacity)
                #if DEBUG
                debugPrint("macOS battery level: \(level)")
                #endif
                return level
            }
        }
        return nil

        #else
        return nil
        #endif
    }

    public static let CPUModel: String = {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpuBrand = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpuBrand, &size, nil, 0)
        return String(cString: cpuBrand)
    }()

    public static let DEV_type: DEV_TYPE = {
        #if targetEnvironment(simulator)
            #if arch(x86_64) || arch(i386)
            return .INTEL_SIMULATOR
            #elseif arch(arm64)
            return .ARM_SIMULATOR
            #else
            return .INTEL_SIMULATOR // 默认
            #endif
        #elseif os(iOS) || os(tvOS) || os(watchOS)
            return .IPHONE
            #elseif os(macOS)
                #if arch(x86_64) || arch(i386)
                return .INTEL_MAC
                #elseif arch(arm64)
                return .APPLE_SILICON_MAC
                #endif
            #else
            return .MAC
        #endif
    }()

    public static let CPU_type: CPU_TYPE = {

        let cpuModel = PerformanceInfo.CPUModel

        switch cpuModel {
        case "Apple M1": return .M1_APPLE
        case "Apple M1 Pro": return .M1_PRO_APPLE
        case "Apple M1 Max": return .M1_MAX_APPLE
        case "Apple M1 Ultra": return .M1_ULTRA_APPLE
        case "Apple M2": return .M2_APPLE
        case "Apple M2 Pro": return .M2_PRO_APPLE
        case "Apple M2 Max": return .M2_MAX_APPLE
        case "Apple M2 Ultra": return .M2_ULTRA_APPLE
        case "Apple M3": return .M3_APPLE
        case "Apple M3 Pro": return .M3_PRO_APPLE
        case "Apple M3 Max": return .M3_MAX_APPLE
        case "Apple M3 Ultra": return .M3_ULTRA_APPLE
        case "Apple M4": return .M4_APPLE
        case "Apple M4 Pro": return .M4_PRO_APPLE
        case "Apple M4 Max": return .M4_MAX_APPLE
        case "Apple M4 Ultra": return .M4_ULTRA_APPLE
        // A 系列 iPhone / iPad
        case "Apple A4": return .A4_APPLE
        case "Apple A5": return .A5_APPLE
        case "Apple A5X": return .A5X_A6X_APPLE
        case "Apple A6": return .A6_APPLE
        case "Apple A7": return .A7_APPLE
        case "Apple A8": return .A8_APPLE
        case "Apple A8X": return .A8X_APPLE
        case "Apple A9": return .A9_APPLE
        case "Apple A9X": return .A9X_APPLE
        case "Apple A10 Fusion": return .A10_APPLE
        case "Apple A10X Fusion": return .A10_A10X_APPLE
        case "Apple A11 Bionic": return .A11_APPLE
        case "Apple A11X Bionic": return .A11X_A12_APPLE
        case "Apple A12 Bionic": return .A12_APPLE
        case "Apple A12X Bionic": return .A12X_APPLE
        case "Apple A13 Bionic": return .A13_APPLE
        case "Apple A14 Bionic": return .A14_APPLE
        case "Apple A15 Bionic": return .A15_APPLE
        case "Apple A16 Bionic": return .A16_APPLE
        case "Apple A17 Pro": return .A17_APPLE
        case "Apple A18": return .A18_APPLE
        case "Apple A18 Pro": return .A18_PRO_APPLE
        case "Apple A19": return .A19_APPLE
        case "Apple A19 Pro": return .A19_PRO_APPLE

        // 默认处理
        default:
            #if arch(x86_64)
                return .INTEL_X64
            #elseif arch(i386)
                return .INTEL_X86
            #elseif arch(arm64)

                if cpuModel.hasPrefix("Apple M") {
                    return .UpperThanM4
                }

                if cpuModel.hasPrefix("Apple A") {
                    return .UpperThanA19
                }

            #endif
            return .UNKNOWN
        }

    }()

    public static let performanceLevel: PerformanceLevel = {

        let cpuTypeRaw = PerformanceInfo.CPU_type.rawValue

        switch DEV_type {
        case .IPHONE:

            if cpuTypeRaw >= CPU_TYPE.UpperThanA15.rawValue && PerformanceInfo.totalMemoryMB >= 6144 {
                return .highPerf
            }

            if cpuTypeRaw >= CPU_TYPE.A12_APPLE.rawValue && PerformanceInfo.totalMemoryMB >= 4096  {
                return .midPerf
            }

        case .APPLE_SILICON_MAC:

            if cpuTypeRaw > CPU_TYPE.M2_APPLE.rawValue && PerformanceInfo.totalMemoryMB >= 20000 {
                return .highPerf
            }

            if cpuTypeRaw >= CPU_TYPE.M1_APPLE.rawValue {
                return .midPerf
            }

        case .INTEL_MAC:

            if PerformanceInfo.totalMemoryMB > 32768 {
                return .highPerf
            }

            if PerformanceInfo.totalMemoryMB >= 16384 {
                return .midPerf
            }

        case .ARM_SIMULATOR:
            return .midPerf
        case .INTEL_SIMULATOR:
            if PerformanceInfo.totalMemoryMB >= 16384 {
                return .midPerf
            }
        }

        return .lowPerf
    }()

    private static let HOST_VM_INFO_COUNT = MemoryLayout<vm_statistics_data_t>.stride/MemoryLayout<integer_t>.stride

    /*
     Return the total memory capacity of the device in bytes.
     */
    public static var totalMemoryMB: UInt64 {
        return totalMemory / 1024 / 1024
    }

    public static var totalMemory: UInt64 {
        #if os(iOS) || os(tvOS) || os(watchOS)
        // iOS / tvOS / watchOS
        return ProcessInfo.processInfo.physicalMemory
        #elseif os(macOS)
        // macOS
        var size: UInt64 = 0
        var sizeOfSize = MemoryLayout<UInt64>.size
        let result = sysctlbyname("hw.memsize", &size, &sizeOfSize, nil, 0)
        if result == 0 {
            return size
        } else {
            // 备用：使用 ProcessInfo
            return ProcessInfo.processInfo.physicalMemory
        }
        #else
        return 0
        #endif
    }
    /*
     Obtain the available memory capacity (unit: MB)
     Available memory includes free memory and inactive memory used by background processes that are set to tombstone state by the system
     This indicates the amount of memory that the current app can continue to use without receiving a memory warning
     */
    public static func availableMemorySize() -> Float {
        let bytesLengthOfPointer = MemoryLayout<UnsafePointer<Int>>.size

        if bytesLengthOfPointer == 4 {
            // 32bit environment
            var vmStats: vm_statistics = vm_statistics.init()
            let kernReturn: kern_return_t = withUnsafeMutableBytes(of: &vmStats) { pointer in
                var infoCount: mach_msg_type_number_t = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
                guard let baseAddress = pointer.baseAddress else {
                    return 1
                }
                 return host_statistics(mach_host_self(),
                                        HOST_VM_INFO,
                                        baseAddress.assumingMemoryBound(to: integer_t.self),
                                        &infoCount)
            }
            if kernReturn == KERN_SUCCESS {
                return Float(UInt32(vm_page_size) * UInt32(vmStats.free_count + vmStats.inactive_count))
                    / 1024.0
                    / 1024.0
            }
        }

        if bytesLengthOfPointer == 8 {
            // 64bit environment
            var vmStats: vm_statistics64_data_t = vm_statistics64.init()
            let kernReturn: kern_return_t = withUnsafeMutableBytes(of: &vmStats) { pointer in
                var infoCount: mach_msg_type_number_t = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
                guard let baseAddress = pointer.baseAddress else {
                    return 1
                }
                 return host_statistics64(mach_host_self(),
                                        HOST_VM_INFO,
                                        baseAddress.assumingMemoryBound(to: integer_t.self),
                                        &infoCount)
            }

            if kernReturn == KERN_SUCCESS {
                return Float(UInt64(vm_page_size) * UInt64(vmStats.free_count + vmStats.inactive_count))
                    / 1024.0
                    / 1024.0
            }
        }
        return 0.0
    }

    /*
     Gets the amount of memory in the free state
     The use of free memory does not affect the user's switch back to the inactive app that was transferred to the background
     Further limit the memory usage to this value to avoid the background application being killed by the system due to the current app operation
     The value obtained by freeMemorySize() should be used as the current available memory size in cases where other processes in the background tombstone state should not be killed completely by the system, causing the user to switch to another APP and need to be reloaded from external storage
     */
    public static func freeMemorySize() -> Float {
        let bytesLengthOfPointer = MemoryLayout<UnsafePointer<Int>>.size
        if bytesLengthOfPointer == 4 {
            //32bit environment
            var vmStats: vm_statistics = vm_statistics.init()
            let kernReturn: kern_return_t = withUnsafeMutableBytes(of: &vmStats) { pointer in
                var infoCount: mach_msg_type_number_t = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
                guard let baseAddress = pointer.baseAddress else {
                    return 1
                }
                 return host_statistics(mach_host_self(),
                                        HOST_VM_INFO,
                                        baseAddress.assumingMemoryBound(to: integer_t.self),
                                        &infoCount)
            }
            if kernReturn == KERN_SUCCESS {
                return Float(UInt32(vm_page_size) * UInt32(vmStats.free_count))
                    / 1024.0
                    / 1024.0
            }
        } else if bytesLengthOfPointer == 8 {
            //64bit environment
            var vmStats: vm_statistics64_data_t = vm_statistics64.init()
            let kernReturn: kern_return_t = withUnsafeMutableBytes(of: &vmStats) { pointer in
                var infoCount: mach_msg_type_number_t = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
                guard let baseAddress = pointer.baseAddress else {
                    return 1
                }
                 return host_statistics64(mach_host_self(),
                                        HOST_VM_INFO,
                                        baseAddress.assumingMemoryBound(to: integer_t.self),
                                        &infoCount)
            }
            if kernReturn == KERN_SUCCESS {
                return Float(UInt64(vm_page_size) * UInt64(vmStats.free_count))
                    / 1024.0
                    / 1024.0
            }
        }
        return 0.0
    }

    /*
     Gets the memory consumption of current process
    */
    public static func currentProcessMemoryUsage() -> Float {
        var info: task_basic_info = task_basic_info.init()
        let kerr: kern_return_t = withUnsafeMutableBytes(of: &info) { pointer in
            guard let baseAddress = pointer.baseAddress else {
                return 1
            }
            var size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size)
             return task_info(mach_task_self_,
                              task_flavor_t(TASK_BASIC_INFO),
                              baseAddress.assumingMemoryBound(to: integer_t.self), &size)
        }

        if kerr == KERN_SUCCESS {
           return Float(info.resident_size)
                / 1024.0
                / 1024.0
        }
        return 0.0
    }

    private static let TASK_BASIC_INFO_COUNT = MemoryLayout<task_basic_info_data_t>.stride
    / MemoryLayout<natural_t>.stride

    private static var prevCPUInfo: processor_info_array_t?

    private static var numPrevCPUInfo: mach_msg_type_number_t  = 0
    
    /*
     How many cpus the current device has
     */
    public static let numOfCPUs: UInt32 = {
        var mib = [CTL_HW, HW_NCPU]
        var sizeOfNumCPUs: size_t = MemoryLayout<u_int>.size
        var numCPUs: UInt32 = 1
        let status = sysctl(&mib,
                             u_int(2),
                             &numCPUs,
                             &sizeOfNumCPUs,
                             nil,
                             0)
        if status != 0 {
            numCPUs = 1
        }
        return numCPUs
    }()

    /*
     What percentage of CPU resources are being used by each thread in the current process
     */
    public static func cpuUsageForEveryThread() -> [thread_t: Float]? {
        var tinfo = [integer_t](repeating: integer_t(0), count: Int(TASK_INFO_MAX))
        var task_info_count: mach_msg_type_number_t = mach_msg_type_number_t(TASK_INFO_MAX)
        let kr: kern_return_t = task_info(mach_task_self_,
                                          task_flavor_t(TASK_BASIC_INFO),
                                          &tinfo,
                                          &task_info_count)
        if kr == KERN_SUCCESS {
            var thread_list: thread_array_t?
            var thread_count: mach_msg_type_number_t = 0
            var thinfo = [integer_t](repeating: integer_t(100), count: Int(THREAD_INFO_MAX))
            var thread_info_count: mach_msg_type_number_t = mach_msg_type_number_t(THREAD_INFO_MAX)
            // Gets all threads' information for the current process
            let kerr: kern_return_t = task_threads(mach_task_self_,
                                                   &thread_list,
                                                   &thread_count)
            if kerr == KERN_SUCCESS {
                guard let thread_list = thread_list else {
                    return nil
                }
                var tot_cpu: Float = 0.0
                var occupationsForEveryThread = [thread_t: Float]()
                var index = 0
                //Statistics the number of CPU resources used by each thread
                while index < thread_count {
                    let thread_id = thread_list[index]
                    let kr = thread_info(thread_id,
                                         thread_flavor_t(THREAD_BASIC_INFO),
                                         &thinfo,
                                         &thread_info_count)
                    if kr != KERN_SUCCESS {
                        return nil
                    }
                    thinfo.withUnsafeBytes { pointer in
                            guard let baseAddress = pointer.baseAddress else {
                                return
                            }
                            let basic_info_th = baseAddress.assumingMemoryBound(to: thread_basic_info.self).pointee
                            let usage = Float(basic_info_th.cpu_usage)
                                        / Float(TH_USAGE_SCALE)
                                        * 100
                            if basic_info_th.flags & TH_FLAGS_IDLE == 0 {
                                //The thread is not idle
                                tot_cpu += usage
                                occupationsForEveryThread[thread_id] = usage
                            }
                    }
                    index += 1
                }
                let kern = vm_deallocate(mach_task_self_,
                                         vm_offset_t(bitPattern: thread_list),
                                         vm_size_t(thread_count * mach_msg_type_number_t(MemoryLayout<thread_t>.size)))
                if kern != KERN_SUCCESS {
                    return nil
                }
                return occupationsForEveryThread
            }
        }
        return nil
    }

    /*
     Total CPU resources consumed by current process
     */
    public static func processLevelCPUusage() -> Float {
        guard let cpuUsages = cpuUsageForEveryThread() else {
            return -1.0
        }
        var totalUsage: Float = 0.0
        for (_, value) in cpuUsages {
            totalUsage += value
        }
        return totalUsage
    }

    /*
     Occupied percentage of each CPU
     */
    public static func occupationForEveryCPU() -> [Float]? {

        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = mach_msg_type_number_t(TASK_BASIC_INFO_COUNT)
        var numCPUsU: natural_t = natural_t(UInt(0))
        let kerr = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCPUInfo)

        if kerr == KERN_SUCCESS {
            var index = 0
            guard let cpuInfo = cpuInfo else {
                return nil
            }
            let numCPUs = Int(numCPUsU)
            var cpuUsages = [Float](repeating: 0.0, count: Int(numCPUsU))
            while index < numCPUs {
                var inUse: integer_t = 0
                var total: integer_t = 0
                if let prevCPUInfo = prevCPUInfo {
                    inUse = cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_USER)]
                    - prevCPUInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_USER)]
                    + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_SYSTEM)]
                    - prevCPUInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_SYSTEM)]
                    + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_NICE)]
                    - prevCPUInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_NICE)]
                    total = inUse
                    + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_IDLE)]
                    - prevCPUInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_IDLE)]
                } else {
                    //Usage for every CPU
                    inUse = cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_USER)]
                            + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_SYSTEM)]
                            + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_NICE)]

                    total = inUse + cpuInfo[(Int(CPU_STATE_MAX) * index) + Int(CPU_STATE_IDLE)]
                }
                let currentCpuUsage = Float(inUse) / Float(total)
                cpuUsages[index] = currentCpuUsage
                index += 1
            }

            if prevCPUInfo != nil {
                let prevCpuInfoSize = mach_msg_type_number_t(MemoryLayout<integer_t>.size) * numPrevCPUInfo
                vm_deallocate(mach_task_self_, vm_offset_t(bitPattern: prevCPUInfo), vm_size_t(prevCpuInfoSize))
            }
            prevCPUInfo = cpuInfo
            numPrevCPUInfo = numCPUInfo
            return cpuUsages
        }
        return nil
    }

    /*
     Total CPU usage of the current device
     */
    public static func deviceLevelCPUusage() -> Float {
        guard let arrayOfUsage = occupationForEveryCPU() else {
            return -1.0
        }
        var totalUsage: Float = 0.0
        for usage in arrayOfUsage {
            totalUsage += usage
        }
        return totalUsage
    }

    /*
     Obtain the creation time of the current process,
     which is mostly used to calculate the startup time consumption of the App.
     */

    public static var processStartTimestamp: TimeInterval {

        // 使用 sysctl 获取进程信息
        let pid = getpid()
        var kinfo = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        var sizeKinfo = MemoryLayout<kinfo_proc>.stride

        let result = sysctl(&mib, UInt32(mib.count), &kinfo, &sizeKinfo, nil, 0)
        if result == 0 {
            let sec = Double(kinfo.kp_proc.p_un.__p_starttime.tv_sec)
            let usec = Double(kinfo.kp_proc.p_un.__p_starttime.tv_usec)
            return sec + usec / 1_000_000.0
        } else {
            // 备用方法：使用 ProcessInfo uptime
            let now = Date().timeIntervalSince1970
            let uptime = ProcessInfo.processInfo.systemUptime
            return now - uptime
        }
    }

}
