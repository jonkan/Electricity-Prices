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
    assert(isRunningForSnapshots(), "Don't use this function outside of snapshots")
#if os(watchOS)
    return false
#else
    return true
#endif
}
