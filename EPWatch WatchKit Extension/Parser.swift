//
//  Parser.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation
import XMLCoder

func parseDayAheadPrices(fromXML data: Data) throws -> DayAheadPrices {
    let decoder = XMLDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    decoder.keyDecodingStrategy = .convertFromCapitalized
    let dayAheadPrices = try decoder.decode(DayAheadPrices.self, from: data)
    return dayAheadPrices
}

