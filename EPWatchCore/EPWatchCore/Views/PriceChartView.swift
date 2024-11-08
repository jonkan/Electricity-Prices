//
//  File.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Charts
import WidgetKit

public struct PriceChartView: View {

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let priceRange: PriceRange
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let useCurrencyAxisFormat: Bool
    let showPriceLimitsLines: Bool
    let cheapestHours: CheapestHours?
    let minHeight: CGFloat?

    @Binding var selectedPrice: PricePoint?
    var displayedPrice: PricePoint {
        return selectedPrice ?? currentPrice
    }

    public init(
        selectedPrice: Binding<PricePoint?> = .constant(nil),
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle,
        useCurrencyAxisFormat: Bool = false,
        showPriceLimitsLines: Bool = false,
        cheapestHours: CheapestHours? = nil,
        minHeight: CGFloat? = nil
    ) {
        _selectedPrice = selectedPrice
        self.currentPrice = currentPrice
        self.prices = prices
        self.priceRange = prices.priceRange() ?? .zero
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
        self.useCurrencyAxisFormat = useCurrencyAxisFormat
        self.showPriceLimitsLines = showPriceLimitsLines
        self.cheapestHours = cheapestHours
        self.minHeight = minHeight
    }

    public var body: some View {
        GeometryReader { geometry in
            chart(geometry)
                .widgetAccentable()
                .chartYAxis {
                    chartYAxis()
                }
                .chartXAxis {
                    chartXAxis(compact: geometry.size.width < 180)
                }
                .chartOverlay { chart in
                    chartGestureOverlay(chart: chart, geometry: geometry)
                }
        }
        .frame(minHeight: minHeight)
    }

    @ViewBuilder
    private func chart(_ geometry: GeometryProxy) -> some View {
        switch chartStyle {
        case .lineInterpolated: lineChart(geometry, interpolated: true)
        case .line: lineChart(geometry, interpolated: false)
        case .bar: barChart(geometry)
        }
    }

    private func lineChart(_ geometry: GeometryProxy, interpolated: Bool) -> some View {
        Chart {
            ForEach(prices, id: \.date) { p in
                LineMark(
                    x: .value("", p.date),
                    y: .value("", pricePresentation.adjustedPrice(p))
                )
            }
            .interpolationMethod(interpolated ? .monotone : .stepEnd)
            .foregroundStyle(LinearGradient(
                stops: limits.stops(using: priceRange),
                startPoint: .bottom,
                endPoint: .top
            ))

            if interpolated {
                currentPriceRuleMark(displayedPrice.date)
                currentPricePointMark(displayedPrice.date)
            } else {
                // A bar the width of an hour
                let barWidth = geometry.size.width / (CGFloat(prices.count) + 1)
                currentPriceBarMark(barWidth: barWidth)
                // Show the point in the middle of the hour
                let hourCenterDate = displayedPrice.date.addingTimeInterval(30*60)
                currentPricePointMark(hourCenterDate)
            }
            priceLimitLines
        }
    }

    private func currentPriceRuleMark(_ date: Date) -> some ChartContent {
        RuleMark(
            x: .value("", date)
        )
        .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [3, 6]))
        .foregroundStyle(.gray)
    }

    @ChartContentBuilder
    private func currentPricePointMark(_ date: Date) -> some ChartContent {
        if widgetRenderingMode == .fullColor {
            PointMark(
                x: .value("", date),
                y: .value("", pricePresentation.adjustedPrice(displayedPrice))
            )
            .foregroundStyle(.foreground.opacity(0.6))
            .symbolSize(300)

            PointMark(
                x: .value("", date),
                y: .value("", pricePresentation.adjustedPrice(displayedPrice))
            )
            .foregroundStyle(.background)
            .symbolSize(100)
        }

        PointMark(
            x: .value("", date),
            y: .value("", pricePresentation.adjustedPrice(displayedPrice))
        )
        .foregroundStyle(limits.color(of: displayedPrice.price))
        .symbolSize(70)
    }

    private func barChart(_ geometry: GeometryProxy) -> some View {
        let barWidth = geometry.size.width / (CGFloat(prices.count)*1.5+1)
        return Chart {
            currentPriceBarMark(barWidth: barWidth)
            cheapestHoursBarMarks(barWidth: barWidth)

            ForEach(prices, id: \.date) { p in
                BarMark(
                    x: .value("", p.date),
                    y: .value("", pricePresentation.adjustedPrice(p)),
                    width: .fixed(barWidth)
                )
                .offset(x: barWidth / 2)
                .foregroundStyle(
                    cheapestHours?.includes(p) == true
                    ? .purple.opacity(0.5)
                    : limits.color(of: p.price)
                )
            }

            priceLimitLines
        }
        .chartXScale(range: .plotDimension(endPadding: barWidth))
    }

    private func currentPriceBarMark(barWidth: CGFloat) -> some ChartContent {
        BarMark(
            x: .value("", displayedPrice.date),
            width: .fixed(barWidth)
        )
        .offset(x: barWidth / 2)
        .foregroundStyle(.gray.opacity(0.3))
    }

    @ChartContentBuilder
    private func cheapestHoursBarMarks(barWidth: CGFloat) -> some ChartContent {
        if let cheapestHours {
            ForEach(cheapestHours.priceDates, id: \.self) { date in
                BarMark(
                    x: .value("", date),
                    width: .fixed(barWidth)
                )
                .offset(x: barWidth / 2)
            }
            .foregroundStyle(.purple.opacity(0.3))
        }
    }

    @ChartContentBuilder
    private var priceLimitLines: some ChartContent {
        if showPriceLimitsLines {
            RuleMark(
                y: .value("", pricePresentation.adjustedPrice(limits.high, in: limits.currency))
            )
            RuleMark(
                y: .value("", pricePresentation.adjustedPrice(limits.low, in: limits.currency))
            )
        }
    }

    private func chartGestureOverlay(chart: ChartProxy, geometry: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(dragGesture(chart: chart, geometry: geometry))
    }

    private func dragGesture(chart: ChartProxy, geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let origin = geometry[chart.plotAreaFrame].origin
                let size = geometry[chart.plotAreaFrame].size
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

    @State private var selectionResetTimer: DispatchSourceTimer?
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

// MARK: - Preview

private struct PriceChartViewPreview: View {
    @State var viewMode: PriceChartViewMode = .todayAndComingNight

    var body: some View {
        let prices: [PricePoint] = .mockPricesWithTomorrow.filterForViewMode(viewMode)
        List {
            Section {
                ForEach(PriceChartStyle.allCases) { style in
                    PriceChartView(
                        currentPrice: prices[21],
                        prices: prices,
                        limits: .mocked,
                        pricePresentation: .init(),
                        chartStyle: style,
                        showPriceLimitsLines: false,
                        cheapestHours: prices.cheapestHours(for: 4)
                    )
                }
                .frame(minHeight: 150)
                .padding(.vertical)
            } header: {
                Picker(selection: $viewMode) {
                    ForEach(PriceChartViewMode.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                } label: {
                    EmptyView()
                }
#if !os(watchOS)
                .pickerStyle(.segmented)
#endif
            }
        }
    }
}

#Preview {
    PriceChartViewPreview()
}
