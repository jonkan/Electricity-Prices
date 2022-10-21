//
//  ComplicationController.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import ClockKit
import SwiftDate
import Combine

class ComplicationController: NSObject, CLKComplicationDataSource {

    var didUpdateDayAheadPricesCancellable: AnyCancellable?

    override init() {
//        let server = CLKComplicationServer.sharedInstance()
//        server.activeComplications?.forEach({ complication in
//            server.reloadTimeline(for: complication)
//        })

        didUpdateDayAheadPricesCancellable = NotificationCenter.default
            .publisher(for: AppState.didUpdateDayAheadPrices)
            .sink { _ in
                let server = CLKComplicationServer.sharedInstance()
                server.activeComplications?.forEach({ complication in
                    server.extendTimeline(for: complication)
                })
            }
    }

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "complication",
                displayName: "EPWatch",
                supportedFamilies: [
                    CLKComplicationFamily.graphicCircular
                ]
            )
            // Multiple complication support can be added here with more descriptors
        ]
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        let lastPricePointDate = AppState.shared.prices?.last?.start
        handler(lastPricePointDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        Task {
            do {
                try await AppState.shared.updatePricesIfNeeded()
                guard let pricePoint = AppState.shared.prices?.price(for: Date()) else {
                    throw NSError(0, "Unable to read pricePoint for current timeline")
                }
                let entry = getTimelineEntry(for: complication, pricePoint: pricePoint)
                handler(entry)
            } catch {
                LogError(error)
                handler(nil)
            }
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        Task {
            var entries: [CLKComplicationTimelineEntry] = []
            for pricePoint in AppState.shared.prices ?? [] {
                guard date < pricePoint.start else {
                    continue
                }
                guard entries.count < limit else {
                    return
                }
                guard let entry = getTimelineEntry(for: complication, pricePoint: pricePoint) else {
                    continue
                }
                entries.append(entry)
            }
            handler(entries)
        }
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }

    func getTimelineEntry(for complication: CLKComplication, pricePoint: PricePoint) -> CLKComplicationTimelineEntry? {
        let price = pricePoint.price
        switch complication.family {
        case .graphicCircular:
            let gauge = CLKSimpleGaugeProvider(
                style: .ring,
                gaugeColors: [.green, .yellow, .red],
                gaugeColorLocations: [0.2, 0.4, 1.0],
                fillFraction: price < 1 ? 0.1 : price < 3 ? 0.4 : 1.0
            )
            let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(
                gaugeProvider: gauge,
                bottomTextProvider: CLKSimpleTextProvider(text: pricePoint.formattedTimeInterval(.short)),
                centerTextProvider: CLKSimpleTextProvider(text: pricePoint.formattedPrice(.short))
            )
            return CLKComplicationTimelineEntry(date: pricePoint.start, complicationTemplate: template)
        default:
            return nil
        }
    }

}
