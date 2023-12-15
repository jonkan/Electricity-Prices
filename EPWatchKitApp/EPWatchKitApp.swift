//
//  EPWatchApp.swift
//  EPWatchKitApp
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore

@main
struct EPWatchKitApp: App {

    @Environment(\.scenePhase) private var scenePhase
    private let hostSyncManager: HostSyncManager

    init() {
#if DEBUG
        LogDebugInformation()
#endif
        hostSyncManager = HostSyncManager(appState: AppState.shared)
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppState.shared)
                .environmentObject(hostSyncManager)
        }
        .onChange(of: scenePhase) {
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (scenePhase == .active)
        }

        WKNotificationScene(
            controller: NotificationController.self,
            category: "myCategory"
        )
    }
}
