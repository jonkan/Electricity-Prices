//
//  File.swift
//  Core
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
    @State var selectionResetTimer: DispatchSourceTimer?

    private var cheapestHoursUnderlineWidth: CGFloat {
        return cheapestHours != nil ? 4 : 0
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
                    chartYAxis(compact: geometry.size.height < 65)
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
        let barWidth = geometry.size.width / CGFloat(prices.count + 1)
        return Chart {
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
                // Add an extra line mark at the end to get the last line segment, e.g. 23:00-00:00.
                if let last = prices.last {
                    LineMark(
                        x: .value("", last.date.addingTimeInterval(3600)),
                        y: .value("", pricePresentation.adjustedPrice(last))
                    )
                }
                // A bar the width of an hour
                currentPriceBarMark(barWidth: barWidth)
                // Show the point in the middle of the hour
                let hourCenterDate = displayedPrice.date.addingTimeInterval(30*60)
                currentPricePointMark(hourCenterDate)
            }
            priceLimitLines
        }
        .chartYScale(range: .plotDimension(startPadding: cheapestHoursUnderlineWidth))
        .chartBackground { chart in
            cheapestHoursUnderline(chart: chart, geometry: geometry, barWidth: barWidth)
        }
    }

    private func currentPriceRuleMark(_ date: Date) -> some ChartContent {
        RuleMark(
            x: .value("", date),
            yStart: cheapestHoursUnderlineWidth
        )
        .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [3, 6]))
        .offset(y: -cheapestHoursUnderlineWidth)
        .foregroundStyle(Color(.chartSelectedRule))
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
        let barWidth = geometry.size.width / (CGFloat(prices.count-1)*1.5+1)
        return Chart {
            currentPriceBarMark(barWidth: barWidth)

            ForEach(prices, id: \.date) { p in
                BarMark(
                    x: .value("", p.date),
                    y: .value("", pricePresentation.adjustedPrice(p)),
                    width: .fixed(barWidth),
                    stacking: .unstacked
                )
                .foregroundStyle(
                    pricePresentation.adjustment.isEnabled && chartStyle == .bar(.dimmed)
                    ? barColor(for: p).dimmed()
                    : barColor(for: p)
                )

                // Show a divider between the spot and adjusted price by
                // overlaying a background colored bar, then a regular bar.
                if pricePresentation.adjustment.isEnabled, chartStyle != .bar(.off) {
                    BarMark(
                        x: .value("", p.date),
                        y: .value("", pricePresentation.spotPrice(p)),
                        width: .fixed(barWidth),
                        stacking: .unstacked
                    )
                    .offset(y: -2)
                    .foregroundStyle(.background.secondary)
                    .cornerRadius(0)

                    BarMark(
                        x: .value("", p.date),
                        y: .value("", pricePresentation.spotPrice(p)),
                        width: .fixed(barWidth),
                        stacking: .unstacked
                    )
                    .foregroundStyle(barColor(for: p))
                    .cornerRadius(0)
                }
            }
            .offset(x: barWidth / 2)

            priceLimitLines
        }
        .chartXScale(range: .plotDimension(endPadding: barWidth))
        .chartYScale(range: .plotDimension(startPadding: cheapestHoursUnderlineWidth))
        .chartBackground { chart in
            cheapestHoursUnderline(chart: chart, geometry: geometry, barWidth: barWidth)
        }
    }

    private func barColor(for pricePoint: PricePoint) -> Color {
        var color = limits.color(of: pricePoint.price)
        if pricePoint == displayedPrice, #available(iOS 18.0, *), #available(watchOS 11.0, *) {
            color = color.mix(with: .black, by: 0.3)
        }
        return color
    }

    private func currentPriceBarMark(barWidth: CGFloat) -> some ChartContent {
        BarMark(
            x: .value("", displayedPrice.date),
            yStart: cheapestHoursUnderlineWidth,
            width: .fixed(barWidth)
        )
        .offset(x: barWidth / 2, y: -cheapestHoursUnderlineWidth)
        .foregroundStyle(Color(.chartSelectedBar))
    }

    @ViewBuilder
    private func cheapestHoursUnderline(chart: ChartProxy, geometry: GeometryProxy, barWidth: CGFloat) -> some View {
        if cheapestHours?.priceDates.isEmpty == false,
           let startX = chart.position(forX: cheapestHours!.priceDates.first!),
           let lastX = chart.position(forX: cheapestHours!.priceDates.last!) {

            let endX = lastX + barWidth
            let y = chart.plotSize.height

            Path { path in
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: endX, y: y))
            }
            .stroke(
                Color(.chartUnderlineCheapestHours),
                style: StrokeStyle(
                    lineWidth: cheapestHoursUnderlineWidth,
                    lineCap: .round
                )
            )
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

}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedPrice: PricePoint?
    @Previewable @State var viewMode: PriceChartViewMode = .todayAndComingNight
    @Previewable @State var priceAdjustmentStyle: PriceAdjustmentStyle = .dimmed

    let prices: [PricePoint] = .mockedPricesWithTomorrow2.filterForViewMode(viewMode)
    let currentPrice = prices[21]

    List {
        Section {
            VStack {
                Text(
                    selectedPrice?.date ?? currentPrice.date,
                    format: .dateTime.hour(.twoDigits(amPM: .abbreviated))
                )
                ForEach(PriceChartStyle.mainStyles) { style in
                    PriceChartView(
                        selectedPrice: $selectedPrice,
                        currentPrice: currentPrice,
                        prices: prices,
                        limits: .mocked,
                        pricePresentation: .mockedWithAdjustments,
                        chartStyle: style.isBar ? .bar(priceAdjustmentStyle) : style,
                        showPriceLimitsLines: false,
                        cheapestHours: prices.cheapestHours(for: 4),
                        minHeight: 130
                    )
                    .padding(.vertical)
                }
            }
        } header: {
            VStack {
                Picker(selection: $viewMode) {
                    ForEach(PriceChartViewMode.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                } label: {
                    EmptyView()
                }
                Picker(selection: $priceAdjustmentStyle) {
                    ForEach(PriceAdjustmentStyle.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                } label: {
                    EmptyView()
                }
            }
#if !os(watchOS)
            .pickerStyle(.segmented)
#endif
        }
    }
}

private extension Color {
    func dimmed() -> Color {
        if #available(iOS 18.0, watchOS 11.0, *) {
            mix(with: .white, by: 0.3)
        } else {
            opacity(0.7)
        }
    }
}
