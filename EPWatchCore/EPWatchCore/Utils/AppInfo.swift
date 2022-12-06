//
//  AppInfo.swift
//  
//
//  Created by Jonas Bromö on 2022-12-06.
//

import UIKit

#if os(watchOS)
import WatchKit
#endif

public struct AppInfo {

    public static var bundleDisplayName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }

    public static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    public static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    public static var commit: String {
        return Bundle.main.object(forInfoDictionaryKey: "GitCommitHash") as? String ?? ""
    }

    public static var systemVersion: String {
#if os(iOS)
        return UIDevice.current.systemVersion
#elseif os(watchOS)
        return WKInterfaceDevice.current().systemVersion
#else
        return "unknown"
#endif
    }

}
