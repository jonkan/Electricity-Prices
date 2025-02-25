//
//  EntsoeDayAheadPricesErrorResponse.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-25.
//

import Foundation

struct EntsoeDayAheadPricesErrorResponse: Codable {
    let reason: Reason

    struct Reason: Codable {
        var code: Int
        var text: String
    }
}

extension UserPresentableError {
    init(_ error: EntsoeDayAheadPricesErrorResponse) {
        if error.reason.code == 999 {
            self = .noData
        } else {
            let message = "DayAheadPricesErrorResponse: \(error.reason.code), \(error.reason.text)"
            self = .unknown(NSError(0, message))
        }
    }
}
