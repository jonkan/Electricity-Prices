//
//  UserDefaults+AppGroup.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-15.
//

import Foundation

extension UserDefaults {

    static let appGroup: UserDefaults = {
        guard let appGroup = UserDefaults(suiteName: "group.EPWatch") else {
            LogError("Failed to create app group UserDefaults")
            return .standard
        }
        return appGroup
    }()

}
