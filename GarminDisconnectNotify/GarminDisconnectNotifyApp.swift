//
//  GarminDisconnectNotifyApp.swift
//  GarminDisconnectNotify
//
//  Created by proken_2025a_map on 2025/07/26.
//

import SwiftUI

@main
struct GarminDisconnectNotifyApp: App {
    // インスタンスを保持してアプリ存続中は常時監視
    @StateObject private var watcher = BLEWatcher()

    var body: some Scene {
        WindowGroup {
            ContentView()   // UI はシンプルで OK
        }
    }
}

