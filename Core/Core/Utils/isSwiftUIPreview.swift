//
//  isSwiftUIPreview.swift
//  Core
//
//  Created by Jonas Bromö on 2022-11-02.
//

import Foundation

public func isSwiftUIPreview() -> Bool {
#if DEBUG
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
    return false
#endif
}
