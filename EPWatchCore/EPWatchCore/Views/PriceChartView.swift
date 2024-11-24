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

    private let selectedPriceColor: Color = .gray.opacity(0.5)
    private let cheapestHoursColor: Color = .purple.opacity(0.5)
    private let cheapestHoursColorDarkened: Color = .purple.opacity(0.7)

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
                    chartYAxis(compact: geometry.size.height < 60)
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
            cheapestHoursRectangleMark
            priceLimitLines
        }
    }

    @ChartContentBuilder
    private var cheapestHoursRectangleMark: some ChartContent {
        if let cheapestHours {
            RectangleMark(
                xStart: .value("", cheapestHours.start),
                xEnd: .value("", cheapestHours.end)
            )
            .foregroundStyle(cheapestHoursColor)
            .cornerRadius(4)
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
                .foregroundStyle(barColor(for: p))
            }

            priceLimitLines
        }
        .chartXScale(range: .plotDimension(endPadding: barWidth))
    }

    private func barColor(for pricePoint: PricePoint) -> Color {
        var color: Color
        if cheapestHours?.includes(pricePoint) == true {
            color = cheapestHoursColorDarkened
        } else {
            color = limits.color(of: pricePoint.price)
        }
        if pricePoint == displayedPrice, #available(iOS 18.0, *), #available(watchOS 11.0, *) {
            color = color.mix(with: .black, by: 0.3)
        }
        return color
    }

    private func currentPriceBarMark(barWidth: CGFloat) -> some ChartContent {
        BarMark(
            x: .value("", displayedPrice.date),
            width: .fixed(barWidth)
        )
        .offset(x: barWidth / 2)
        .foregroundStyle(selectedPriceColor)
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
            .foregroundStyle(cheapestHoursColor)
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

@available(iOS 17, watchOS 10, *)
#Preview {
    @Previewable @State var selectedPrice: PricePoint?
    @Previewable @State var viewMode: PriceChartViewMode = .todayAndComingNight

    let prices: [PricePoint] = .mockedPricesWithTomorrow2.filterForViewMode(viewMode)
    let currentPrice = prices[21]

    List {
        Section {
            VStack {
                Text(
                    selectedPrice?.date ?? currentPrice.date,
                    format: .dateTime.hour(.twoDigits(amPM: .abbreviated))
                )
                ForEach(PriceChartStyle.allCases) { style in
                    PriceChartView(
                        selectedPrice: $selectedPrice,
                        currentPrice: currentPrice,
                        prices: prices,
                        limits: .mocked,
                        pricePresentation: .mocked,
                        chartStyle: style,
                        showPriceLimitsLines: false,
                        cheapestHours: prices.cheapestHours(for: 4),
                        minHeight: 130
                    )
                    .padding(.vertical)
                }
            }
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
