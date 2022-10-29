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

    public var short: String {
        switch self {
        case .noData:
            return "Unfortunately no data was found.".localized
        case .noExchangeRate:
            return "Failed to fetch an up-to-date exchange rate.".localized
        case .unknown:
            return "An unknown error occurred.".localized
        }
    }

    public var long: String {
        return short
    }
}
