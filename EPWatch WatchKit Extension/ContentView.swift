//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import Charts

struct ContentView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        if let currentPrice = state.currentPrice {
            VStack(spacing: 8) {
                Text(currentPrice.formattedPrice(.regular))
                    .font(.title)
                Text(currentPrice.formattedTimeInterval(.regular))
                    .font(.subheadline)
                Chart {
                    ForEach(state.todaysPrices, id: \.start) { p in
                        LineMark(
                            x: .value("", p.start),
                            y: .value("Kr", p.price)
                        )
                    }
                    RuleMark(
                        x: .value("", currentPrice.start)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 4]))
                    .foregroundStyle(.gray)
                    PointMark(
                        x: .value("", currentPrice.start),
                        y: .value("Kr", currentPrice.price)
                    )
                }
            }
            .padding()
        } else {
            Text("Loading current price...")
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static let state: AppState = {
        let s = AppState.shared
        s.prices = [
            PricePoint(
                price: 1.23,
                start: Date().dateAtStartOf([.hour])
            ),
            PricePoint(
                price: 3.21,
                start: Date().dateAtStartOf([.hour]) + 1.hours.timeInterval
            ),
            PricePoint(
                price: 2.31,
                start: Date().dateAtStartOf([.hour]) + 2.hours.timeInterval
            )
        ]
        s.currentPrice = PricePoint(
            price: 1.23,
            start: Date().dateAtStartOf([.hour])
        )
        return s
    }()

    static var previews: some View {
        ContentView()
            .environmentObject(state)
    }
}
