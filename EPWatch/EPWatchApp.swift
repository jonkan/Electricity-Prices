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
    private let watchSyncManager: WatchSyncManager

    init() {
#if DEBUG
        LogDebugInformation()
#endif
        watchSyncManager = WatchSyncManager(appState: AppState.shared)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppState.shared)
                .environmentObject(ShareLogsState.shared)
                .environmentObject(watchSyncManager)
        }
        .onChange(of: scenePhase) { phase in
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (phase == .active) 
        }
    }
}
