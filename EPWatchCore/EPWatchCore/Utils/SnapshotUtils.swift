//
//  SnapshotUtils.swift
//  Electricity Prices UI Tests
//
//  Created by Jonas Bromö on 2024-04-20.
//

import Foundation

public func isRunningForSnapshots() -> Bool {
#if DEBUG
    UserDefaults.appGroup.bool(forKey: "FASTLANE_SNAPSHOT")
#else
    false
#endif
}

public func use941ForSnapshots() -> Bool {
#if os(watchOS)
    false
#else
    true
#endif
}
