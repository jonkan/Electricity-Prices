//
//  WCSessionActivationState+Description.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-28.
//

import WatchConnectivity

public extension WCSessionActivationState {
    var description: String {
        switch self {
        case .notActivated: return "Not activated"
        case .inactive: return "Inactive"
        case .activated: return "Activated"
        @unknown default: return "unknown default"
        }
    }
}
