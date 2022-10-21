//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private var state: AppState = .shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let price = state.formattedCurrentPrice {
                Text(price)

            } else {
                Text("Loading current price...")
            }
        }
        .padding()
        .onChange(of: scenePhase) { phase in
            state.isTimerRunning = (phase == .active)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
