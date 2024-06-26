//
//  File.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Charts
import WidgetKit

// swiftlint:disable type_body_length
public struct PriceChartView: View {

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @Environment(\.widgetFamily) private var widgetFamily

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let priceRange: ClosedRange<Double>
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let useCurrencyAxisFormat: Bool
    let isChartGestureEnabled: Bool
    let showPriceLimitsLines: Bool
    @Binding var selectedPrice: PricePoint?
    var displayedPrice: PricePoint {
        return selectedPrice ?? currentPrice
    }

    public init(
        selectedPrice: Binding<PricePoint?>,
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle,
        useCurrencyAxisFormat: Bool = false,
        isChartGestureEnabled: Bool = true,
        showPriceLimitsLines: Bool = false
    ) {
        _selectedPrice = selectedPrice
        self.currentPrice = currentPrice
        self.prices = prices
        self.priceRange = prices.priceRange() ?? 0.0...0.0
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
        self.useCurrencyAxisFormat = useCurrencyAxisFormat
        self.isChartGestureEnabled = isChartGestureEnabled
        self.showPriceLimitsLines = showPriceLimitsLines
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
    }

    @ViewBuilder
    private func chart(_ geometry: GeometryProxy) -> some View {
        switch chartStyle {
        case .lineInterpolated: lineChart(geometry, interpolated: true)
        case .line: lineChart(geometry, interpolated: false)
        case .bar: barChart(geometry)
        }
    }

    @AxisContentBuilder
    private func chartYAxis() -> some AxisContent {
#if os(watchOS)
        // This avoids the axis labels from being clipped on the rectangular watch widget
        let preset: AxisMarkPreset = widgetFamily == .accessoryRectangular ? .extended : .aligned
#else
        let preset: AxisMarkPreset = .aligned
#endif
        if let axisYValues = axisYValues {
            // Figure out how to present subdivided units (e.g. Cent)
            if useCurrencyAxisFormat && pricePresentation.currencyPresentation != .subdivided {
                AxisMarks(format: currencyAxisFormat, preset: preset, values: axisYValues)
            } else {
                AxisMarks(preset: preset, values: axisYValues)
            }
        } else {
            if useCurrencyAxisFormat && pricePresentation.currencyPresentation != .subdivided {
                AxisMarks(format: currencyAxisFormat, preset: preset)
            } else {
                AxisMarks(preset: preset)
            }
        }
    }

    @AxisContentBuilder
    private func chartXAxis(compact: Bool) -> some AxisContent {
        let isShowing2Days = prices.count >= 48
        AxisMarks(
            values: isShowing2Days && compact ? .automatic(desiredCount: 2) : .automatic
        ) { value in
            if let date = value.as(Date.self) {
                let calendar: Calendar = .current
                let hour = calendar.component(.hour, from: date)
                if isShowing2Days {
                    AxisValueLabel {
                        if hour == 0 {
                            if calendar.isDateInToday(date) {
                                Text("Today", bundle: .module)
                                    .minimumScaleFactor(0.5)
                            } else if calendar.isDateInTomorrow(date) {
                                Text("Tomorrow", bundle: .module)
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text(date, format: .dateTime.month(.abbreviated).day())
                            }
                        } else {
                            Text(date, format: .dateTime.hour())
                        }
                    }
                } else {
                    AxisValueLabel()
                }

                if hour == 0 {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    AxisTick(stroke: StrokeStyle(lineWidth: 1))
                } else {
                    AxisGridLine()
                    AxisTick()
                }
            }
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

            ForEach(prices, id: \.date) { p in
                BarMark(
                    x: .value("", p.date),
                    y: .value("", pricePresentation.adjustedPrice(p)),
                    width: .fixed(barWidth)
                )
                .offset(x: barWidth / 2)
                .foregroundStyle(limits.color(of: p.price))
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

    private var axisYValues: [Double]? {
        let adjustedDayPriceRange = pricePresentation.adjustedPriceRange(currentPrice.dayPriceRange)
        // The minimum axis values prevents relatively low prices from being presented as very tall 
        // bars (or the equivalent).
        let minimumYAxisValues = currentPrice.currency.minimumYAxisValues
        if adjustedDayPriceRange.upperBound <= minimumYAxisValues.last! &&
            pricePresentation.currencyPresentation != .subdivided {
            return minimumYAxisValues
        }
        return nil
    }

    private var currencyAxisFormat: FloatingPointFormatStyle<Double>.Currency {
        let adjustedDayPriceRange = pricePresentation.adjustedPriceRange(currentPrice.dayPriceRange)
        if adjustedDayPriceRange.upperBound <= 10 {
            return .currency(code: currentPrice.currency.code).precision(.fractionLength(1))
        }
        return .currency(code: currentPrice.currency.code).precision(.significantDigits(2))
    }

    private func chartGestureOverlay(chart: ChartProxy, geometry: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                dragGesture(chart: chart, geometry: geometry),
                including: isChartGestureEnabled ? .all : .subviews
            )
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
        List {
            Section {
                ForEach(PriceChartStyle.allCases) { style in
                    PriceChartView(
                        selectedPrice: .constant(nil),
                        currentPrice: [PricePoint].mockPricesWithTomorrow[21],
                        prices: .mockPricesWithTomorrow.filterForViewMode(viewMode),
                        limits: .mockLimits,
                        pricePresentation: .init(),
                        chartStyle: style,
                        isChartGestureEnabled: true,
                        showPriceLimitsLines: false
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
