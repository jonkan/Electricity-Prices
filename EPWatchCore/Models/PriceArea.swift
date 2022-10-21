//
//  PriceArea.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

public struct PriceArea: Codable, Identifiable, Equatable {
    public var title: String
    public var id: String
    public var code: String
}
