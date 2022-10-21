//
//  EPWatchApp.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore

@main
struct EPWatchApp: App {

    @Environment(\.scenePhase) private var scenePhase

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(AppState.shared)
            }
        }
        .onChange(of: scenePhase) { phase in
            AppState.shared.isTimerRunning = (phase == .active)
        }

        WKNotificationScene(
            controller: NotificationController.self,
            category: "myCategory"
        )
    }
}
