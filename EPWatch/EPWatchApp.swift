//
//  EPWatchApp.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

@main
struct EPWatchApp: App {

    @Environment(\.scenePhase) private var scenePhase

    init() {
#if DEBUG
        LogDebugInformation()
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState.shared)
        }
        .onChange(of: scenePhase) { phase in
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (phase == .active)
        }
    }
}
