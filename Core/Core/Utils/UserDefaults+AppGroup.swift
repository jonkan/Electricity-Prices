//
//  UserDefaults+AppGroup.swift
//  Core
//
//  Created by Jonas Bromö on 2022-09-15.
//

import Foundation

public extension UserDefaults {

    static let appGroup: UserDefaults = {
        guard let appGroup = UserDefaults(suiteName: .appGroupIdentifier) else {
            LogError("Failed to create app group UserDefaults")
            return .standard
        }
        return appGroup
    }()

}
