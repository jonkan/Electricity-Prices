//
//  ElectricityPricesWatchApp.swift
//  ElectricityPricesWatchApp
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore

@main
struct ElectricityPricesWatchApp: App {

    @Environment(\.scenePhase) private var scenePhase
    private let hostSyncManager: HostSyncManager

    init() {
#if DEBUG
        LogDebugInformation()
#endif
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            UserDefaults.appGroup.set(true, forKey: "FASTLANE_SNAPSHOT")
        } else {
            UserDefaults.appGroup.set(false, forKey: "FASTLANE_SNAPSHOT")
        }

        hostSyncManager = HostSyncManager(appState: AppState.shared)
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(AppState.shared)
                .environmentObject(hostSyncManager)
        }
        .onChange(of: scenePhase) {
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (scenePhase == .active)
        }
    }

}
