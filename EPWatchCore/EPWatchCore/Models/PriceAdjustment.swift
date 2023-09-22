//
//  PriceAdjustment.swift
//  
//
//  Created by Jonas Bromö on 2022-12-08.
//

import Foundation

public struct PriceAdjustment: Codable, Equatable {

    public struct Addend: Codable, Equatable, Identifiable {
        public var id: Int
        public var title: String = ""
        public var value: Double = 0
    }

    public var isEnabled: Bool
    public var multiplier: Double
    public var addends: [Addend] = []

    public init(
        isEnabled: Bool,
        multiplier: Double = 1.25,
        addends: [Addend] = []
    ) {
        self.isEnabled = isEnabled
        self.multiplier = multiplier
        self.addends = addends
    }

    public func adjustedPrice(_ price: Double) -> Double {
        if isEnabled {
            return (price + addends.map({ $0.value }).reduce(0, +)) * multiplier
        } else {
            return price
        }
    }

    public mutating func addAddend() {
        addends.append(
            Addend(id: (addends.map({ $0.id }).max() ?? -1) + 1)
        )
    }

}
