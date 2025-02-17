//
//  Locale+Helpers.swift
//  Core
//
//  Created by Jonas Värbrand on 2024-11-23.
//

import Foundation

extension Locale {

    var is24Hour: Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self)
        return dateFormat?.firstIndex(of: "a") == nil
    }

}
