//
//  PriceChartView+Gestures.swift
//  Core
//
//  Created by Jonas Värbrand on 2025-02-20.
//

import SwiftUI
import Charts

extension PriceChartView {

    func chartGestureOverlay(chart: ChartProxy, geometry: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(dragGesture(chart: chart, geometry: geometry))
    }

    private func dragGesture(chart: ChartProxy, geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let plotFrame = chart.plotFrame else {
                    return
                }
                let origin = geometry[plotFrame].origin
                let size = geometry[plotFrame].size
                let location = CGPoint(
                    x: max(origin.x, min(value.location.x - origin.x, size.width)),
                    y: max(origin.y, min(value.location.y - origin.y, size.height))
                )
                guard let selectedDate = chart.value(atX: location.x, as: Date.self) else {
                    Log("Failed to find selected X value")
                    return
                }

                let secondsToFirst = selectedDate.timeIntervalSince(prices.first?.date ?? .distantPast)
                let selectedIndex = Int(round(secondsToFirst / 60 / 60))
                let price = prices[safe: selectedIndex]

                if selectedPrice != price {
                    selectedPrice = price
                    SelectionHaptics.shared.changed()
                }
                cancelSelectionResetTimer()
            }
            .onEnded { _ in
                scheduleSelectionResetTimer(in: .milliseconds(500)) {
                    selectedPrice = nil
                    SelectionHaptics.shared.ended()
                }
            }
    }

    private func scheduleSelectionResetTimer(
        in timeout: DispatchTimeInterval,
        handler: @escaping () -> Void
    ) {
        if selectionResetTimer == nil {
            let timerSource = DispatchSource.makeTimerSource(queue: .global())
            timerSource.setEventHandler {
                Task {
                    cancelSelectionResetTimer()
                    handler()
                }
            }
            selectionResetTimer = timerSource
            timerSource.resume()
        }
        selectionResetTimer?.schedule(
            deadline: .now() + timeout,
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
    }

    private func cancelSelectionResetTimer() {
        selectionResetTimer?.cancel()
        selectionResetTimer = nil
    }

}
