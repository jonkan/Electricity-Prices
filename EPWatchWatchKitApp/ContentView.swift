//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore
import Charts

struct ContentView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        if let currentPrice = state.currentPrice {
            VStack(spacing: 8) {
                Text(currentPrice.formattedPrice(.normal))
                    .font(.title)
                Text(currentPrice.formattedTimeInterval(.normal))
                    .font(.subheadline)
                Chart {
                    ForEach(state.todaysPrices, id: \.date) { p in
                        LineMark(
                            x: .value("", p.date),
                            y: .value("Kr", p.price)
                        )
                    }
                    RuleMark(
                        x: .value("", currentPrice.date)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 4]))
                    .foregroundStyle(.gray)
                    PointMark(
                        x: .value("", currentPrice.date),
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
                date: Date().dateAtStartOf([.hour]),
                price: 1.23
            ),
            PricePoint(
                date: Date().dateAtStartOf([.hour]) + 1.hours.timeInterval,
                price: 3.21
            ),
            PricePoint(
                date: Date().dateAtStartOf([.hour]) + 2.hours.timeInterval,
                price: 2.31
            )
        ]
        s.currentPrice = PricePoint(
            date: Date().dateAtStartOf([.hour]),
            price: 1.23
        )
        return s
    }()

    static var previews: some View {
        ContentView()
            .environmentObject(state)
    }
}
