//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation

struct PricePoint: Codable {
    var price: Double
    var start: Date // And 1h forward
}
