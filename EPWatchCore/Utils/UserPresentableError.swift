//
//  UserPresentableError.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-25.
//

import Foundation

public enum UserPresentableError: Error {
    case noData
    case noExchangeRate(_ error: Error)
    case unknown(_ error: Error)

    public var localizedDescription: String {
        return description.localized
    }

    private var description: String {
        switch self {
        case .noData:
            return "Unfortunately no data was found for the selected price area."
        case .noExchangeRate:
            return "Failed to fetch an up-to-date exchange rate."
        case .unknown:
            return "An unknown error occurred."
        }
    }

    public var debugDescription: String {
        return String(describing: self)
    }

}
