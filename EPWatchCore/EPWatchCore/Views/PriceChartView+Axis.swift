//
//  PriceChartView+Axis.swift
//  EPWatchCore
//
//  Created by Jonas Värbrand on 2024-11-08.
//

import SwiftUI
import Charts

extension PriceChartView {

    static let twoDigitHourDateFormatter: DateFormatter = .twoDigitHourFormat()

    @AxisContentBuilder
    func chartYAxis() -> some AxisContent {
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
    func chartXAxis(compact: Bool) -> some AxisContent {
        let isShowing2Days = prices.count >= 48
        AxisMarks { value in
            if let date = value.as(Date.self) {
                let calendar: Calendar = .current
                let hour = calendar.component(.hour, from: date)
                if compact {
                    AxisValueLabel {
                        Text(Self.twoDigitHourDateFormatter.string(from: date))
                    }
                } else if isShowing2Days {
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

    private var axisYValues: [Double]? {
        let adjustedDayPriceRange = pricePresentation.adjustedPriceRange(priceRange)
        // The minimum axis values prevents relatively low prices from being presented as very tall
        // bars (or the equivalent).
        let minimumYAxisValues = currentPrice.currency.minimumYAxisValues
        if adjustedDayPriceRange.max <= minimumYAxisValues.last! &&
            pricePresentation.currencyPresentation != .subdivided {
            return minimumYAxisValues
        }
        return nil
    }

    private var currencyAxisFormat: FloatingPointFormatStyle<Double>.Currency {
        let adjustedDayPriceRange = pricePresentation.adjustedPriceRange(priceRange)
        if adjustedDayPriceRange.max <= 10 {
            return .currency(code: currentPrice.currency.code).precision(.fractionLength(1))
        }
        return .currency(code: currentPrice.currency.code).precision(.significantDigits(2))
    }

}
