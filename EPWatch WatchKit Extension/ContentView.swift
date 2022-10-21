//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var state: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let pricePoint = state.currentPrice {
                VStack(spacing: 8) {
                    Text(pricePoint.formattedPrice(.regular))
                        .font(.title)
                    Text(pricePoint.formattedTimeInterval(.regular))
                        .font(.subheadline)
                }
                .padding()
            } else {
                Text("Loading current price...")
                    .padding()
            }
        }
        .onChange(of: scenePhase) { phase in
            state.isTimerRunning = (phase == .active)
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static let state: AppState = {
        let s = AppState.shared
        s.currentPrice = PricePoint(
            price: 3.24,
            start: Date().dateAtStartOf([.hour])
        )
        return s
    }()

    static var previews: some View {
        ContentView()
            .environmentObject(state)
    }
}
