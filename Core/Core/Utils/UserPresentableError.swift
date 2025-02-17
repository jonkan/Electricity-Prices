//
//  UserPresentableError.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-25.
//

import Foundation

public enum UserPresentableError: Error {
    case noData
    case noCurrentPrice
    case noExchangeRate(_ error: Error)
    case unknown(_ error: Error)

    public var localizedDescription: String {
        return description
    }

    private var description: String {
        switch self {
        case .noData:
            return String(localized: "Unfortunately no data was found for the selected price area.", bundle: .module)
        case .noCurrentPrice:
            return String(localized: "Failed to fetch the current price.", bundle: .module)
        case .noExchangeRate:
            return String(localized: "Failed to fetch an up-to-date exchange rate.", bundle: .module)
        case .unknown:
            return String(localized: "An unknown error occurred.", bundle: .module)
        }
    }

    public var debugDescription: String {
        return String(describing: self)
    }

}
