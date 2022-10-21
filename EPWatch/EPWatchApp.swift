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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState.shared)
        }
        .onChange(of: scenePhase) { phase in
            AppState.shared.isTimerRunning = (phase == .active)
        }
    }
}
