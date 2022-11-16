//
//  Log.swift
//  Log
//
//  Created by Jonas Bromö on 2022-07-13.
//

import Foundation
import CoreLocation
@_implementationOnly import XCGLogger

#if DEBUG
public func LogDebugInformation() {
    Log(
"""
Debug information:
\tDocuments directory: \(FileManager.default.documentsDirectory().path())
\tApp Group directory: \(FileManager.default.appGroupDirectory().path())
\tMain bundle: \(Bundle.main.bundlePath)
"""
    )
}
#endif

public enum LogLevel {
    case debug, error
}

public func LogError(
    _ error: Error?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
) {
    guard let error = error else {
        return
    }
    let nsError = error as NSError
    let message: String
    if nsError.domain == kCLErrorDomain, let code = CLError.Code(rawValue: nsError.code) {
        switch code {
        case .locationUnknown: message = "locationUnknown"
        case .denied: message = "denied"
        case .network: message = "network"
        case .headingFailure: message = "headingFailure"
        case .regionMonitoringDenied: message = "regionMonitoringDenied"
        case .regionMonitoringFailure: message = "regionMonitoringFailure"
        case .regionMonitoringSetupDelayed: message = "regionMonitoringSetupDelayed"
        case .regionMonitoringResponseDelayed: message = "regionMonitoringResponseDelayed"
        case .geocodeFoundNoResult: message = "geocodeFoundNoResult"
        case .geocodeFoundPartialResult: message = "geocodeFoundPartialResult"
        case .geocodeCanceled: message = "geocodeCanceled"
        case .deferredFailed: message = "deferredFailed"
        case .deferredNotUpdatingLocation: message = "deferredNotUpdatingLocation"
        case .deferredAccuracyTooLow: message = "deferredAccuracyTooLow"
        case .deferredDistanceFiltered: message = "deferredDistanceFiltered"
        case .deferredCanceled: message = "deferredCanceled"
        case .rangingUnavailable: message = "rangingUnavailable"
        case .rangingFailure: message = "rangingFailure"
        case .promptDeclined: message = "promptDeclined"
        case .historicalLocationError: message = "historicalLocationError"
        @unknown default: message = "unknown"
        }
    } else {
        message = String(describing: error)
    }

    LogError(
        message,
        file: file,
        function: function,
        line: line
    )
}

public func LogError(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
) {
   Log(
    message,
    file: file,
    function: function,
    line: line,
    level: .error
   )
}

fileprivate let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.formatterBehavior = .behavior10_4
    df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return df
}()

public func Log(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    level: LogLevel = .debug
) {
    logger.logln(
        level.xcgLevel,
        functionName: function,
        fileName: file,
        lineNumber: line,
        closure: { message }
    )
}

private var logger: XCGLogger = {
    // Create a logger object with no destinations
    let log = XCGLogger(identifier: "Logger", includeDefaultDestinations: false)

    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "Logger.systemDestination")

    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true

    // Add the destination to the logger
    log.add(destination: systemDestination)

    // Create a file log destination
    let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    let logFileName = "\(bundleName).log"
    let logFileUrl = FileManager.default.logFilesDirectory().appending(path: logFileName)
    if !FileManager.default.fileExists(atPath: logFileUrl.path()) {
        try? FileManager.default.createDirectory(
            atPath: logFileUrl.deletingLastPathComponent().path(),
            withIntermediateDirectories: true
        )
    }
    let fileDestination = AutoRotatingFileDestination(
        writeToFile: logFileUrl.path(),
        identifier: "Logger.fileDestination"
    )

    // Optionally set some configuration options
    fileDestination.outputLevel = .debug
    fileDestination.showLogIdentifier = false
    fileDestination.showFunctionName = true
    fileDestination.showThreadName = true
    fileDestination.showLevel = true
    fileDestination.showFileName = true
    fileDestination.showLineNumber = true
    fileDestination.showDate = true

    // Process this destination in the background
    fileDestination.logQueue = XCGLogger.logQueue

    // Add the destination to the logger
    log.add(destination: fileDestination)

    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()
    return log
}()

private extension LogLevel {
    var xcgLevel: XCGLogger.Level {
        switch self {
        case .debug: return .debug
        case .error: return .error
        }
    }
}
