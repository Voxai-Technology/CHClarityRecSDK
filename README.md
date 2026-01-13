# CHClarityRecSDK Usage Guide

> This document describes how to integrate and use **CHClarityRecSDK**.
>
> * ✅ Supported integration: **Swift Package Manager (SPM)**
> * ❌ CocoaPods is **not supported** at the moment
> * ⚠️ **Internal network / Wi-Fi related APIs are intentionally NOT covered** in this guide

---

## 1. Overview

**CHClarityRecSDK** is a Bluetooth-based SDK built on **CoreBluetooth**, designed for controlling recording devices.

Main capabilities include:

* Bluetooth device scanning, connection, and disconnection
* Device information queries (version, battery, storage)
* Recording control (start / pause / resume / stop)
* Device file management (list, download, delete)
* Device control (time sync, rename, find device, format storage)
* OTA firmware upgrade

The SDK uses a **protocol + singleton** architecture, exposing only stable public interfaces for easy integration.

---

## 2. Integration via Swift Package Manager (SPM)

### Add the package in Xcode

1. Open **Project Settings → Package Dependencies**
2. Click **+**
3. Enter the repository URL:

```
https://github.com/Voxai-Technology/CHClarityRecSDK.git
```

4. Select the desired version (latest tag or `main` branch recommended)
5. Finish adding the package

---

## 3. Required Configuration

### Info.plist Permissions

Bluetooth permission is required:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Used to connect and manage the recording device</string>
```

If background scanning or connection is needed:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

---

## 4. SDK Initialization

The SDK **must be initialized once at app launch**.

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

> ⚠️ Ensure Bluetooth permission has been granted before using the SDK

---

## 5. Accessing the SDK Instance

The SDK exposes a shared singleton instance:

```swift
let sdk = CHClarityRecSDKManager.shared
```

All device-related operations are performed through this instance, which conforms to `CHClarityRecSDKProtocol`.

---

## 6. Delegate Setup

### 6.1 Device Data Delegate (Required)

```swift
sdk.delegate = self
```

Used to receive data actively pushed by the device (e.g. streaming data, device status updates).

> Delegate callbacks are invoked on a **background thread**. Switch to the main thread for UI updates.

---

### 6.2 Bluetooth Delegate (Strongly Recommended)

```swift
sdk.bluetoothDelegate = self
```

Used to monitor:

* Bluetooth connection and disconnection
* Connection failures
* Device state changes

This is the **primary way** to track device connection status.

---

## 7. Device Scanning & Connection

### 7.1 Start Scanning

```swift
sdk.ch_startScanning(
    namePrefixes: ["CH-"],
    serviceUUIDs: nil,
    timeout: 10
) { devices, error in
    if let error = error {
        debugPrint("Scan error: \(error)")
        return
    }
    debugPrint("Scanned devices:", devices)
}
```

Notes:

* Supports filtering by device name prefix and service UUID
* Automatically de-duplicates devices
* Automatically stops scanning after timeout

---

### 7.2 Stop Scanning

```swift
sdk.ch_stopScanning()
```

Recommended when:

* The target device is found
* The current view disappears

This helps reduce battery consumption.

---

### 7.3 Connect to a Device

#### Option 1: Connect using deviceId

```swift
sdk.ch_connect(toDevice: deviceId) { success, error in
    debugPrint("Connect result:", success, error ?? "")
}
```

#### Option 2: Connect using CHPeripheral

```swift
sdk.ch_connect(toDevice: peripheral) { success, error in
    debugPrint("Connect result:", success)
}
```

> Final connection state changes are delivered via `bluetoothDelegate`.

---

### 7.4 Disconnect

```swift
sdk.ch_disconnect()
```

After disconnection, all device operations become unavailable until reconnected.

---

## 8. Device Information Queries

### Query Basic Device Information

```swift
let info = try await sdk.ch_querySystemDeviceInfo()
```

### Query Storage Information

```swift
let info = try await sdk.ch_queryDeviceStorage()
```

### Query Battery Level

```swift
let info = try await sdk.ch_queryDeviceBattery()
```

### Query File Count

```swift
let count = try await sdk.ch_queryDeviceFileCount()
```

---

## 9. Recording Control

```swift
// Start recording
try await sdk.ch_operateDeviceRecord(operationCode: 1)

// Pause recording
try await sdk.ch_operateDeviceRecord(operationCode: 2)

// Resume recording
try await sdk.ch_operateDeviceRecord(operationCode: 3)

// Stop and save recording
try await sdk.ch_operateDeviceRecord(operationCode: 0)
```

---

## 10. File Management

### Get File List

```swift
let files = try await sdk.ch_getFileList(isMore: false, pageSize: 10)
```

### Delete Files

```swift
try await sdk.ch_batchDeleteFiles([
    (index: 0, fileName: "REC_001.wav")
])
```

### Download Files

```swift
let stream = try await sdk.ch_downloadDeviceFile(config: config)

for try await event in stream {
    debugPrint(event)
}
```

---

## 11. Device Control

### Sync System Time

```swift
try await sdk.ch_setSystemTimeToDevice()
```

### Find Device

```swift
try await sdk.ch_findRecorderDevice(isOpen: true)
```

### Rename Device

```swift
try await sdk.ch_changeDeviceName("MyRecorder")
```

### Format Storage

```swift
try await sdk.ch_formatDeviceStorage(type: 1)
```

---

## 12. OTA Firmware Upgrade

```swift
sdk.ch_uploadOTAFile(
    file: firmwareData,
    progress: { progress in
        debugPrint("Progress:", progress)
    },
    completion: { success, error in
        debugPrint("OTA result:", success, error ?? "")
    }
)
```

---

## 13. Restart / Power Off Device

```swift
// Restart device
try await sdk.ch_setDeviceRestart(bool: true)

// Power off device
try await sdk.ch_setDeviceRestart(bool: false)
```

---

## 14. Error

- **errorCode**: Unique numeric code for SDK and higher-level communication  
- **Case**: Swift enum case  
- **Description**: Short description of the error  
- **Reason**: Optional detailed cause for the error  

| Error Code | Case | Description | Reason |
|------------|------|-------------|--------|
| 1001 | `deviceNotConnected` | Device is not connected. | Occurs when calling an API while the device is not connected (e.g., `queryBattery`, `operateRecord`) |
| 2001 | `bluetooth` | CoreBluetooth system error | Underlying system Bluetooth error, may include an `NSError` object |
| 2002 | `bluetoothRejected` | Device rejected the operation | Device returned a business-level failure. Example reasons: `"Empty device info response"`, `"Record operation failed"`, `"Change device name failed"`, `"Reset device failed"` |
| 3001 | `fileIO` | File system operation failed | Local file operation failed, e.g., write or read failure |
| 3002 | `invalidFileData` | Invalid file data | Downloaded data is invalid, CRC or offset mismatch. Reason example: `"File size mismatch"` |
| 3003 | `downloadCancelled` | Download was cancelled | Download interrupted by user or system |
| 9000 | `unknown` | Unknown error | Fallback for uncaught errors, may contain underlying `Error` |

---


---

## 15. Notes & Best Practices

* All async APIs must be called **after the device is connected**
* Delegate callbacks are executed on background threads
* Only one device connection is supported at a time
* Do not disconnect during file transfer or OTA operations
* WIFI-AP mode is handled by the upper-level business logic (SDK file downloads will automatically use the WiFi channel depending on whether the device is connected to WIFI-AP).
---
