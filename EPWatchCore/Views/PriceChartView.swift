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

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let currencyPresentation: CurrencyPresentation
    let useCurrencyAxisFormat: Bool

    @Binding var displayedPrice: PricePoint

    public init(
        displayedPrice: Binding<PricePoint>,
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation,
        useCurrencyAxisFormat: Bool = false
    ) {
        _displayedPrice = displayedPrice
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
        self.useCurrencyAxisFormat = useCurrencyAxisFormat
    }

    public var body: some View {
        Chart {
            ForEach(prices, id: \.date) { p in
                LineMark(
                    x: .value("", p.date),
                    y: .value("", p.price(with: currencyPresentation))
                )
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(LinearGradient(
                stops: limits.stops(using: displayedPrice.dayPriceRange),
                startPoint: .bottom,
                endPoint: .top
            ))

            RuleMark(
                x: .value("", displayedPrice.date)
            )
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [3, 6]))
            .foregroundStyle(.gray)

            if widgetRenderingMode == .fullColor {
                PointMark(
                    x: .value("", displayedPrice.date),
                    y: .value("", displayedPrice.price(with: currencyPresentation))
                )
                .foregroundStyle(.foreground.opacity(0.6))
                .symbolSize(300)

                PointMark(
                    x: .value("", displayedPrice.date),
                    y: .value("", displayedPrice.price(with: currencyPresentation))
                )
                .foregroundStyle(.background)
                .symbolSize(100)
            }

            PointMark(
                x: .value("", displayedPrice.date),
                y: .value("", displayedPrice.price(with: currencyPresentation))
            )
            .foregroundStyle(limits.color(of: displayedPrice.price))
            .symbolSize(70)
        }
        .widgetAccentable()
        .chartYAxis {
            if let axisYValues = axisYValues {
                // TODO: Figure out how to present subdivided units (e.g. Cent)
                if useCurrencyAxisFormat && currencyPresentation != .subdivided {
                    AxisMarks(
                        format: currencyAxisFormat,
                        values: axisYValues
                    )
                } else {
                    AxisMarks(values: axisYValues)
                }
            } else {
                if useCurrencyAxisFormat && currencyPresentation != .subdivided {
                    AxisMarks(format: currencyAxisFormat)
                } else {
                    AxisMarks()
                }
            }
        }
        .chartOverlay(content: chartGestureOverlay)
        .padding(.top, widgetRenderingMode != .fullColor ? 5 : 0)
    }

    var axisYValues: [Double]? {
        if currentPrice.dayPriceRange.upperBound <= 1.5 && currencyPresentation != .subdivided {
            return [0.0, 0.5, 1.0, 1.5]
        }
        return nil
    }

    var currencyAxisFormat: FloatingPointFormatStyle<Double>.Currency {
        if currentPrice.dayPriceRange.upperBound <= 10 {
            return .currency(code: currentPrice.currency.code).precision(.fractionLength(1))
        }
        return .currency(code: currentPrice.currency.code).precision(.significantDigits(2))
    }

    func chartGestureOverlay(_ proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Color.clear.contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let origin = geometry[proxy.plotAreaFrame].origin
                            let size = geometry[proxy.plotAreaFrame].size
                            let location = CGPoint(
                                x: max(origin.x, min(value.location.x - origin.x, size.width)),
                                y: max(origin.y, min(value.location.y - origin.y, size.height))
                            )
                            guard let selectedDate = proxy.value(atX: location.x, as: Date.self) else {
                                Log("Failed to find selected X value")
                                return
                            }
                            let hour = Calendar.current.component(.hour, from: selectedDate)
                            let minute = Calendar.current.component(.minute, from: selectedDate)
                            let roundedHour = minute >= 30 ? hour + 1 : hour
                            let price = prices.first(where: { price in
                                let priceHour = Calendar.current.component(.hour, from: price.date)
                                return roundedHour == priceHour
                            })

                            if let price = price {
                                if displayedPrice != price {
                                    displayedPrice = price
                                    SelectionHaptics.shared.changed()
                                }
                            } else {
                                if displayedPrice != currentPrice {
                                    displayedPrice = currentPrice
                                    SelectionHaptics.shared.changed()
                                }
                            }
                            cancelSelectionResetTimer()
                        }
                        .onEnded { _ in
                            SelectionHaptics.shared.ended()
                            scheduleSelectionResetTimer(in: .milliseconds(500))
                        }
                )
        }
    }

    @State private var selectionResetTimer : DispatchSourceTimer?
    private func scheduleSelectionResetTimer(in timeout: DispatchTimeInterval) {
        if selectionResetTimer == nil {
            let timerSource = DispatchSource.makeTimerSource(queue: .global())
            timerSource.setEventHandler {
                Task {
                    cancelSelectionResetTimer()
                    displayedPrice = currentPrice
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

private extension PricePoint {
    func price(with currencyPresentation: CurrencyPresentation) -> Double {
        switch currencyPresentation {
        case .automatic:
            return price
        case .subdivided:
            return price * currency.subdivision.subdivisions
        }
    }
}

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView(
            displayedPrice: .constant(.mockPrice),
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            currencyPresentation: .automatic
        )
    }
}

