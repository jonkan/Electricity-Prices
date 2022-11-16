//
//  PriceArea.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

public struct PriceArea: Codable, Identifiable, Equatable {
    public let title: String
    public let id: String
    public let code: String
}
