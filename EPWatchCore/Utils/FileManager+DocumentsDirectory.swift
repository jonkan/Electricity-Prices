//
//  FileManager+DocumentsDirectory.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation

extension FileManager {
    public func documentsDirectory() -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func appGroupDirectory() -> URL {
        guard let appGroupURL = containerURL(forSecurityApplicationGroupIdentifier: .appGroupIdentifier) else {
            LogError("Failed to obtain app group directory")
            return documentsDirectory()
        }
        return appGroupURL
    }
}
