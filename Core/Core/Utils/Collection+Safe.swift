//
//  Collection+Safe.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-11-14.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
