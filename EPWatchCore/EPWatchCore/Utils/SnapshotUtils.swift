//
//  SnapshotUtils.swift
//  Electricity Prices UI Tests
//
//  Created by Jonas Bromö on 2024-04-20.
//

import Foundation

public func isRunningForSnapshots() -> Bool {
    UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
}
