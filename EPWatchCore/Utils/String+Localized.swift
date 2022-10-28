//
//  String+Localized.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-24.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
    }
}
