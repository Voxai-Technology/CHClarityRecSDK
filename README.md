# CHClarityRecSDK Usage Guide

> This documentation applies to **CHClarityRecSDK** (supports **Swift Package Manager, SPM** integration only; CocoaPods is not currently supported).
> `Access Wi-Fi Information` Used to obtain the Wi-Fi connection status and network information (e.g., SSID, BSSID) of the current device. This capability typically requires requesting the "Wireless Data" permission or relevant system declarations.
> `Hotspot` Used to detect whether the personal hotspot (Wi-Fi hotspot) function is enabled on the current device, or to manage/connect to a personal hotspot. This capability generally involves Local Network permissions and specific configuration declarations.


---

## I. SDK Overview

CHClarityRecSDK is a recording device control SDK based on **CoreBluetooth**, with the following main capabilities:

* Bluetooth scanning, connection, and disconnection
* Device basic information query (version, battery, storage, etc.)
* Device recording control (start / pause / stop)
* Device file management (list, download, delete)
* Device control (time sync, rename, find device, format, etc.)
* OTA firmware upgrade

The SDK adopts a **protocol + singleton** design pattern, exposing only stable interfaces for easy integration at the business layer.

---

## II. Integration (SPM)

### 1. Adding via Swift Package Manager

In Xcode:

1. Open **Project Settings → Package Dependencies**
2. Click **+**
3. Enter the Git URL:

```url
https://github.com/Voxai-Technology/CHClarityRecSDK.git
```

4. Select the desired version (latest tag / main branch recommended)
5. Complete the addition

---

## III. Required Configuration

### 1. Info.plist Permission Configuration

The SDK is based on Bluetooth communication and **must** configure the following permissions:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Used to connect and manage recording devices</string>
```

For background scanning or connection, add additional configuration:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

---

## IV. SDK Initialization

The SDK **must be initialized once during app launch**.

```swift
import CHClarityRecSDK

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    CHClarityRecSDKManager.initialize()
    return true
}
```

> ⚠️ Ensure Bluetooth permissions are authorized before initialization

---

## V. Getting SDK Instance

The SDK provides capabilities through a singleton pattern:

```swift
let sdk = CHClarityRecSDKManager.shared
```

This instance conforms to `CHClarityRecSDKProtocol`, and all functions are called from this entry point.

---

## VI. Delegate Setup

### 1. Device Data Stream Delegate (Required)

```swift
sdk.delegate = self
```

Used to receive data actively pushed by the device (such as recording stream, device status changes, etc.).

> Callback thread is a **background thread**. Please switch to the main thread for UI operations.

### 2. Bluetooth Status Delegate (Strongly Recommended)

```swift
sdk.bluetoothDelegate = self
```

Used to monitor:

* Bluetooth connection / disconnection
* Connection failure reasons
* Device status changes

This is the **critical delegate** for determining device availability.

---

## VII. Device Scanning and Connection

### 1. Start Scanning

```swift
sdk.ch_startScanning(
    namePrefixes: nil,
    serviceUUIDs: [CBUUID(string: "AF30")],
    timeout: 10
) { devices, error in
    if let error = error {
        debugPrint("Scan error: \(error)")
        return
    }
    debugPrint("Scanned devices:", devices)
}
```

Features:

* Supports **device name / Service UUID** filtering
* Automatic deduplication
* Automatically stops scanning after timeout

---

### 2. Stop Scanning

```swift
sdk.ch_stopScanning()
```

Recommended to call immediately:

* After finding the target device
* When the page disappears

This saves battery power.

---

### 3. Connect to Device

#### Method 1: Using deviceId

```swift
sdk.ch_connect(toDevice: deviceId) { success, error in
    debugPrint("connect result:", success, error ?? "")
}
```

#### Method 2: Using scanned CHPeripheral

```swift
sdk.ch_connect(toDevice: peripheral) { success, error in
    debugPrint("connect result:", success)
}
```

> Connection results and status changes are based on `bluetoothDelegate` callbacks.

---

### 4. Disconnect

```swift
sdk.ch_disconnect()
```

After disconnection, reconnection is required for any device operations.

---

## VIII. Device Information Query

### 1. Query Basic Information

```swift
Task {
    do {
        if let info = try await sdk.ch_querySystemDeviceInfo() {
            print("Device Info:", info.toJSON() ?? [:])
        }
    } catch {
        print("Error querying device info:", error)
    }
}
```

### 2. Query Storage Space

```swift
Task {
    do {
        let storage = try await sdk.ch_queryDeviceStorage()
        print("Total Storage:", storage.totalDiskSpace ?? 0, "MB")
        print("Remaining Storage:", storage.remainDiskSpace ?? 0, "MB")
    } catch {
        print("Error querying storage:", error)
    }
}
```

### 3. Query Battery

```swift
Task {
    do {
        let battery = try await sdk.ch_queryDeviceBattery()
        print("Battery Level:", battery.batteryLevel ?? 0, "%")
        print("Charging:", battery.charging == 1 ? "Yes" : "No")
    } catch {
        print("Error querying battery:", error)
    }
}
```

### 4. Query File Count

```swift
Task {
    do {
        let count = try await sdk.ch_queryDeviceFileCount()
        print("File count:", count)
    } catch {
        print("Error querying file count:", error)
    }
}
```

---

## IX. Recording Control

```swift
Task {
    do {
        // Start recording
        try await sdk.ch_operateDeviceRecord(operationCode: 1)

        // Pause recording
        try await sdk.ch_operateDeviceRecord(operationCode: 2)

        // Resume recording
        try await sdk.ch_operateDeviceRecord(operationCode: 3)

        // Stop recording and save
        try await sdk.ch_operateDeviceRecord(operationCode: 0)
    }
}
```

---

## X. File Management

### 1. Get File List

```swift
Task {
    do {
        let files = try await sdk.ch_getFileList(isMore: false, pageSize: 10)
        for file in files {
            print("File:", file.fileName, "Index:", file.index)
        }
    } catch {
        print("Error getting file list:", error)
    }
}
```

### 2. Delete Files

```swift
Task {
    do {
        try await sdk.ch_batchDeleteFiles([
            (index: 0, fileName: "REC_001.wav")
        ])
        print("Deleted file REC_001.wav")
    } catch {
        print("Error deleting file:", error)
    }
}
```

### 3. Download Files

```swift
Task {
    do {
        let stream = try await sdk.ch_downloadDeviceFile(config: .init(fileIndex: 0))
        for try await event in stream {
            switch event {
            case .progress(let progress):
                print("Download progress:", progress)
            case .completed(let filePath):
                print("Download completed:", filePath)
            case .failed(let error):
                print("Download failed:", error)
            }
        }
    } catch {
        print("Error downloading file:", error)
    }
}
```

---

## XI. Device Control Capabilities

### Sync Time

```swift
try await sdk.ch_setSystemTimeToDevice()
```

### Find Device

```swift
try await sdk.ch_findRecorderDevice(isOpen: true)
```

### Change Device Name

```swift
try await sdk.ch_changeDeviceName("MyRecorder")
```

### Format Storage

```swift
try await sdk.ch_formatDeviceStorage(type: 1)
```

---

## XII. OTA Firmware Upgrade

```swift
(discard ❌)
// It is necessary to detect whether the current device has enabled the Wi-Fi hotspot function and call the `ch_connectInnerNet` method to connect to the device, or independently establish an internal network connection based on the data returned by the device. Afterward, execute the OTA upgrade process. Once the upgrade is complete, to avoid single-channel communication issues, it is advisable to disable the Wi-Fi channel.

Task {
    // 
    let stream = try await sdk.ch_uploadOTAFile(
        config: CHOTAConfigure(
            data: Data(),
            type: .wifiFirmware
        )
    )
    for try await event in stream {
        switch event {
        case .progress(let progress):
            print("progress: \(Int(progress * 100))%")
        case .completed(let data):
            print("✅ OTA upload, size: \(data.count) bytes")
        @unknown default:
            print("Error")
        }
    }
}
sdk.ch_uploadOTAFile(
    config: CHOTAConfigure(
        data: Data(),
        type: .wifiFirmware
    ),
    progress: { progress in
        print("progress: \(Int(progress * 100))%")
    },
    completion: { success, error in
        if success {
            print("✅ OTA success")
        } else {
            print("❌ OTA fail: \(error?.localizedDescription ?? "")")
        }
    }
)
```

---

## XIII. Device Restart / Power Off

```swift

(discard ❌)
Task {
    do {
        try await sdk.ch_setDeviceRestart(bool: true)  // Restart
        print("Device restarted")

        try await sdk.ch_setDeviceRestart(bool: false) // Power off
        print("Device powered off")
    } catch {
        print("Error:", error)
    }
}
```

---

## XIV. Device Binding (Requires Server API Integration)

```swift
Task {
    do {
        // Assuming scode is already obtained
        let scode = "000000"
        try await sdk.ch_bindDeveice(state: .connect, scode: scode)
        print("Device binding success")
    } catch {
        print("Error binding device:", error)
    }
}
```

---

## XV. Enable Device WIFI-AP

```swift
Task {
    do {
        // Turn on WIFI
        if let deviceInfo = try await sdk.ch_operateDeviceWifi(isOpen: true) {
            // When the device WIFI-AP is enabled, connectInnerNet can be used to connect to the device LAN, 
            try await CHClarityRecSDKManager.shared.ch_connectInnerNet()
            print("WIFI enabled, device info:", deviceInfo.toJSON() ?? [:])
        }

        // Turn off WIFI
        if let deviceInfo = try await sdk.ch_operateDeviceWifi(isOpen: false) {
            print("WIFI disabled, device info:", deviceInfo.toJSON() ?? [:])
        }
    } catch {
        print("WIFI control error:", error)
    }
}
```

---

## XVI. Exit Wi-Fi AP mode

```swift
Task {
    do {
        // exit on WIFI-AP
        try await sdk.ch_exitWIFIMode() 
        print("Exit WIFI-AP success.")
    
    } catch {
        print("Exit WIFI-AP error:", error)
    }
}
```


---


## XVII. Set USB Mode

```swift
Task {
    do {
        // Enable USB mode
        try await sdk.ch_setDeviceUSBMode(isOpen: true)
        // Disable USB mode
        try await sdk.ch_setDeviceUSBMode(isOpen: false)
        print("USB mode enabled successfully.")
    } catch {
        print("Failed to set USB mode:", error)
    }
}
```

---

## XVIII. Complete Example

```swift
import CHClarityRecSDK

class RecorderSample {

    let sdk = CHClarityRecSDKManager.shared

    func runSample() async {
        do {

           // 0️⃣ Assuming device is already scanned, or connect using deviceId
           let deviceId = "CH-123456" // Replace with actual device ID
           try await withCheckedThrowingContinuation { continuation in
               sdk.ch_connect(toDevice: deviceId) { success, error in
                   if success {
                       print("Bluetooth device connected")
                       continuation.resume()
                   } else {
                       continuation.resume(throwing: error ?? NSError(domain: "ConnectError", code: -1, userInfo: nil))
                   }
               }
           }

            // 1️⃣ Query device basic information
            guard let deviceInfo = try await sdk.ch_querySystemDeviceInfo() else {
                print("Device info is nil")
                return
            }
            print("Device Info:", deviceInfo.toJSON() ?? [:])

            // 2️⃣ Device binding example (connect state)
            let bindCode = "ABCDE12345" // Replace with actual binding code
            do {
                try await sdk.ch_bindDeveice(state: .connect, scode: bindCode)
                print("Device binding success")
            } catch {
                print("Device binding failed:", error)
                // If binding fails, exit and don't proceed
                return
            }

            // 3️⃣ Query device storage space
            let storageInfo = try await sdk.ch_queryDeviceStorage()
            print("Total Storage:", storageInfo.totalDiskSpace ?? 0, "MB")
            print("Remaining Storage:", storageInfo.remainDiskSpace ?? 0, "MB")

            // 4️⃣ Query device battery
            let batteryInfo = try await sdk.ch_queryDeviceBattery()
            print("Battery Level:", batteryInfo.batteryLevel ?? 0, "%")
            print("Charging Status:", batteryInfo.charging == 1 ? "Charging" : "Not charging")

            // 5️⃣ Query device file count
            let fileCount = try await sdk.ch_queryDeviceFileCount()
            print("File count:", fileCount)

            // 6️⃣ Get file list (pagination example)
            let files = try await sdk.ch_getFileList(isMore: false, pageSize: 10)
            for file in files {
                print("File:", file.fileName, "Index:", file.index)
            }

            // 7️⃣ Delete example file (if exists)
            if !files.isEmpty {
                try await sdk.ch_batchDeleteFiles([
                    (index: files[0].index, fileName: files[0].fileName)
                ])
                print("Deleted file:", files[0].fileName)
            }

            // Turn on WIFI (developers can use the returned ssid and password to connect to the WiFi LAN, 
            // then use the returned ip + port to connect via socket). When connection is successful, 
            // calling `ch_downloadDeviceFile` will automatically use the WiFi channel to download files, 
            // otherwise it will default to using the Bluetooth channel.
            if let deviceInfo = try await sdk.ch_operateDeviceWifi(isOpen: true) {
                // When the device WIFI-AP is enabled, connectInnerNet can be used to connect to the device LAN, 
                try await CHClarityRecSDKManager.shared.ch_connectInnerNet()
                print("WIFI enabled, device info:", deviceInfo.toJSON() ?? [:])
            }

            // 8️⃣ Download file example (streaming)
            guard let file = files.first else {
                return
            }
            let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first!
            let saveURL = documentsURL.appendingPathComponent(file.name ?? "def.ogg")
            let configure = CHDownloadConfigure(fileModel: file, saveTo: saveURL, forceBle: false)

            Task {
                do {
                    let stream = try await CHClarityRecSDKManager.shared
                        .ch_downloadDeviceFile(config: configure)
                    
                    for try await event in stream {
                        switch event {
                        case .progress(let value):
                            debugPrint("progress: \(Int(value * 100))%")
                        case .completed(let data):
                            debugPrint("completed data size: \(data.count)")
                        @unknown default:
                            debugPrint("other error")
                            break
                        }
                    }
                } catch {
                    debugPrint("Error: \(error.localizedDescription)")
                }
            }

            // 9️⃣ Recording control example
            try await sdk.ch_operateDeviceRecord(operationCode: 1) // Start recording
            print("Recording started")

            // 🔟 Device control example
            try await sdk.ch_setSystemTimeToDevice()
            print("System time synced")
            try await sdk.ch_changeDeviceName("MyRecorder")
            print("Device renamed")

            // 1️⃣1️⃣ OTA upgrade example (discard ❌)
            Task {
                let stream = try await sdk.ch_uploadOTAFile(
                    config: CHOTAConfigure(
                        data: Data(),
                        type: .wifiFirmware
                    )
                )
                for try await event in stream {
                    switch event {
                    case .progress(let progress):
                        print("progress: \(Int(progress * 100))%")
                    case .completed(let data):
                        print("✅ OTA upload, size: \(data.count) bytes")
                    @unknown default:
                        print("Error")
                    }
                }
            }
            sdk.ch_uploadOTAFile(
                config: CHOTAConfigure(
                    data: Data(),
                    type: .wifiFirmware
                ),
                progress: { progress in
                    print("progress: \(Int(progress * 100))%")
                },
                completion: { success, error in
                    if success {
                        print("✅ OTA success")
                    } else {
                        print("❌ OTA fail: \(error?.localizedDescription ?? "")")
                    }
                }
            )
        } catch {
            print("Error occurred:", error)
        }
    }
}

// Usage example
CHClarityRecSDKManager.initialize()
let sample = RecorderSample()
Task {
    await sample.runSample()
}
```

---

## XIX. Error Codes

- **errorCode**: Unique identifier for SDK and upper layer communication  
- **Case**: Swift enum name  
- **Description**: Error description  
- **Reason**: Specific error reason (optional)  

| Error Code | Case | Description | Reason |
|------------|------|-------------|--------|
| 1001 | `deviceNotConnected` | Device is not connected | API called while the device is not connected (e.g. queryBattery, operateRecord, etc.) |
| 1002 | `bluetooth` | CoreBluetooth system error | Underlying CoreBluetooth exception, may contain `NSError` |
| 1003 | `bluetoothRejected` | Device rejected the operation | Device-side protocol or business logic rejection, see `CHClarityRecErrorCode` |
| 1004 | `emptyDeviceInfo` | Device info response is empty | Device returned empty or invalid device info data |
| 1005 | `emptyStorageResponse` | Storage info response is empty | Failed to retrieve storage information from device |
| 1006 | `recordOperationFailed` | Recording operation failed | Device failed to start / stop recording |
| 1007 | `emptyBatteryResponse` | Battery info response is empty | Device returned empty battery data |
| 1008 | `noDeviceResponse` | No device response | Device did not respond to the request |
| 1009 | `resetDeviceFailed` | Device reset failed | Device failed to perform reset operation |
| 1010 | `bindDeviceFailed` | Device bind failed | Failed to bind the device |
| 1011 | `downloadCancelled` | Download cancelled | Download was cancelled by user or system |
| 1012 | `fileTransferFailed` | File transfer failed | Device file transfer process failed |
| 1013 | `wifiUnavailable` | Wi-Fi unavailable | Wi-Fi is disabled or not reachable |
| 1014 | `socketConnectFailed` | Socket connection failed | Failed to establish socket connection |
| 1015 | `emptyFindDeviceResponse` | Find device response is empty | Device did not respond to find-device command |
| 1016 | `editNameFailed` | Edit device name failed | Failed to change device name |
| 1017 | `resertFailed` | Device reset failed | Device rejected reset command |
| 1018 | `shutdownFailed` | Device shutdown failed | Device failed to shut down |
| 1019 | `responseFrameError` | Protocol frame error | Protocol data frame incomplete or invalid |
| 1020 | `timeout` | Operation timed out | No response within timeout period |
| 1021 | `characteristicNotFound` | Characteristic not found | Required BLE characteristic missing |
| 1022 | `servicesNotFound` | Service not found | Required BLE service missing |
| 1023 | `retryLimitExceeded` | Retry limit exceeded | Maximum retry attempts reached |
| 1024 | `disconnectBluetooth` | Bluetooth disconnected | Bluetooth connection was unexpectedly disconnected |
| 1025 | `setUSBModeFailed` | Set USB mode failed | Device failed to enter USB mode |
| 1026 | `socketNotConnect` | Socket not connected | Socket is not connected or already closed |
| 2001 | `fileIO` | File system operation failed | Local file read/write failure |
| 2003 | `downloadCancelled` | Download interrupted | Download interrupted at SDK level |
| 3001 | `clearWriteQueue` | Clear write queue | Internal write buffer queue cleared |
| 4001 | `wifiRejected` | Wi-Fi operation rejected | Wi-Fi operation rejected by device or network |
| 9000 | `unknown` | Unknown error | Fallback error, may contain underlying exception |

---

## XX. Important Notes

* All async interfaces **must be called when the device is connected**
* Bluetooth callback thread is a background thread
* Only supports connection to one device at a time
* Do not disconnect during file operations or OTA operations
* WIFI-AP mode is handled by the upper business layer (SDK file download automatically uses WiFi channel when connected to WIFI-AP)

---
