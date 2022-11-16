//
//  Error.swift
//  Error
//
//  Created by Jonas Bromö on 2022-07-13.
//

import Foundation

public extension NSError {

    convenience init(_ code: Int, _ description: String) {
        let userInfo: [String: Any] = [
            NSDebugDescriptionErrorKey: description
        ]
        self.init(
            domain: Bundle.main.bundleIdentifier ?? "",
            code: code,
            userInfo: userInfo
        )
    }

}
