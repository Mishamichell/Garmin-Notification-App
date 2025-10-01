//
//  ContentView.swift
//  GarminDisconnectNotify
//
//  Created by proken_2025a_map on 2025/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
            Text("Garmin Disconnect Notifier")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

