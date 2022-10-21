//
//  Regions.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-14.
//

import Foundation

public enum Region: Codable {
    case sweden

    public var priceAreas: [PriceArea] {
        switch self {
        case .sweden:
            return [
                PriceArea(title: "SE1", domain: "10Y1001A1001A44P"),
                PriceArea(title: "SE2", domain: "10Y1001A1001A45N"),
                PriceArea(title: "SE3", domain: "10Y1001A1001A46L"),
                PriceArea(title: "SE4", domain: "10Y1001A1001A47J"),
            ]
        }
    }
}

public struct PriceArea: Codable, Identifiable, Equatable {
    public var title: String
    public var domain: String

    public var id: String {
        return "\(title)-\(domain)"
    }
}
