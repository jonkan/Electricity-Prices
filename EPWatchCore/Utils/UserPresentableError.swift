//
//  UserPresentableError.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-25.
//

import Foundation

public enum UserPresentableError: Error {
    case noData
    case unknown

    public var short: String {
        switch self {
        case .noData:
            return "Unfortunately, no data was found.".localized
        case .unknown:
            return "An unknown error occurred.".localized
        }
    }

    public var long: String {
        return short
    }
}

extension UserPresentableError {
    init(_ error: Error) {
        self.init(error as NSError)
    }

    init(_ error: NSError) {
        self = .unknown
    }
}
