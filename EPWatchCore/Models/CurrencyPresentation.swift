//
//  CurrencyPresentation.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-23.
//

import Foundation

public enum CurrencyPresentation: String, Codable, CaseIterable, Identifiable, Equatable {
    case natural
    case subdivided

    public var id: String {
        return rawValue
    }
}
