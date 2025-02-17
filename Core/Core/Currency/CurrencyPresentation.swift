//
//  CurrencyPresentation.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-23.
//

import Foundation

public enum CurrencyPresentation: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {
    case automatic
    case subdivided

    public var id: String {
        return rawValue
    }
}
