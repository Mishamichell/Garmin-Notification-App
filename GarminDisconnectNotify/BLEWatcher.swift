//
//  Untitled.swift
//  GarminDisconnectNotify
//
//  Created by proken_2025a_map on 2025/07/26.
//
//
//  BLEWatcher.swift
//  GarminDisconnectNotify
//
//  Created by (Your Name) on 2025/07/26.
//

import Foundation
import CoreBluetooth
import UserNotifications   // ← 通知

/// Garmin 接続を監視し、切断されたらローカル通知を出す
final class BLEWatcher: NSObject,
                        ObservableObject,
                        UNUserNotificationCenterDelegate,
                        CBCentralManagerDelegate,
                        CBPeripheralDelegate {

    // MARK: - Properties
    private var central: CBCentralManager!
    private var target: CBPeripheral?
    private let keyword = "Forerunner 255"    // デバイス名の一部でフィルタ

    // MARK: - Init
    override init() {
        super.init()

        // 通知許可 & デリゲート
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        center.delegate = self          // フォアグラウンド表示用

        // CoreBluetooth 開始
        central = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - UNUserNotificationCenterDelegate
    /// アプリが前面でもバナー＋音を出す
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handler([.banner, .sound])
    }

    // MARK: - Private helpers
    /// ローカル通知
    private func notify(_ body: String) {
        let content = UNMutableNotificationContent()
        content.title = "Garmin 切断"
        content.body  = body
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: UUID().uuidString,
                                       content: content, trigger: nil))
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }

        // 既接続デバイスをログ表示
        let connected = central.retrievePeripherals(withIdentifiers: [])
        print("🔗 already connected:", connected.map { $0.name ?? "nil" })

        // スキャン開始（名前でフィルタ）
        central.scanForPeripherals(withServices: nil,
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        print("🔍 Scanning …")
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard let name = peripheral.name?.lowercased(),
              name.contains(keyword.lowercased()) else { return }

        print("✅ Found", name)
        target = peripheral
        peripheral.delegate = self
        central.stopScan()
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("📶 Connected", peripheral.name ?? "")
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        guard peripheral == target else { return }

        print("⚠️ Disconnected")
        notify("Forerunner 255S Music の Bluetooth 接続が切れました")

        // 再スキャンして再接続待ち
        central.scanForPeripherals(withServices: nil, options: nil)
    }
}
