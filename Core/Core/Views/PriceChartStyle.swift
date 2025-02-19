//
//  PriceChartStyle.swift
//  Core
//
//  Created by Jonas Bromö on 2022-11-15.
//

import SwiftUI

public enum PriceChartStyle: Codable, Identifiable, Equatable, Hashable, Sendable {
    case bar(_ priceAdjustmentStyle: PriceAdjustmentStyle = .off)
    case line
    case lineInterpolated

    public static let mainStyles: [PriceChartStyle] = [.bar(), .line, .lineInterpolated]

    public var id: String {
        switch self {
        case .bar(let priceAdjustmentStyle):
            return "bar-\(priceAdjustmentStyle)"
        case .line:
            return "line"
        case .lineInterpolated:
            return "lineInterpolated"
        }
    }

    public var title: String {
        switch self {
        case .lineInterpolated:
            return String(
                localized: "Line (interpolated)",
                bundle: .module,
                comment: "Chart type"
            )
        case .line:
            return String(
                localized: "Line",
                bundle: .module,
                comment: "Chart type"
            )
        case .bar:
            return String(
                localized: "Bar",
                bundle: .module,
                comment: "Chart type"
            )
        }
    }

    public var isBar: Bool {
        switch self {
        case .bar:
            return true
        default:
            return false
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "bar":
            self = .bar()
        case "bar-divided":
            self = .bar(.divided)
        case "bar-dimmed":
            self = .bar(.dimmed)
        case "line":
            self = .line
        case "lineInterpolated":
            self = .lineInterpolated
        default:
            throw NSError(0, "Unknown \(Self.self) rawValue: \(rawValue)")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var continaer = encoder.singleValueContainer()
        switch self {
        case .bar(let priceAdjustmentStyle):
            switch priceAdjustmentStyle {
            case .off:
                try continaer.encode("bar")
            case .divided:
                try continaer.encode("bar-divided")
            case .dimmed:
                try continaer.encode("bar-dimmed")
            }
        case .line:
            try continaer.encode("line")
        case .lineInterpolated:
            try continaer.encode("lineInterpolated")
        }
    }
}

public enum PriceAdjustmentStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case off
    case divided
    case dimmed

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .off:
            return String(
                localized: "Off",
                bundle: .module,
                comment: "The style not being enabled."
            )
        case .divided:
            return String(
                localized: "Divided",
                bundle: .module,
                comment: "A style to distinguish between the base price and fees in a chart."
            )
        case .dimmed:
            return String(
                localized: "Dimmed",
                bundle: .module,
                comment: "A style to distinguish between the base price and fees in a chart."
            )
        }
    }
}
