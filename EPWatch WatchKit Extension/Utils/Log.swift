//
//  Log.swift
//  Log
//
//  Created by Jonas Bromö on 2022-07-13.
//

import Foundation
import CoreLocation

public func LogError(
    _ error: Error?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
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
    line: UInt = #line
) {
   Log(
    message,
    file: file,
    function: function,
    line: line,
    prefix: "🚨"
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
    line: UInt = #line,
    prefix: String? = nil
) {

    let filename = URL(string: "\(file)")?.lastPathComponent ?? ""
    var fileAndFunc = "\(filename) \(function)"
    if let prefix = prefix {
        fileAndFunc = "\(prefix) \(fileAndFunc)"
    }
    fileAndFunc = fileAndFunc
        .padding(toLength: 50, withPad: " ", startingAt: 0)

    let dateAndTime = dateFormatter.string(from: Date())

    let log = String(
        format: "%@ %@ [Line %5d] %@",
        dateAndTime,
        fileAndFunc,
        line,
        message
    )
    print(log)
}

var LogOnceLoggedMessages = Set<String>()

public func LogOnce(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    prefix: String? = nil
) {
    guard !LogOnceLoggedMessages.contains(message) else {
        return
    }
    LogOnceLoggedMessages.insert(message)
    Log(
        message,
        file: file,
        function: function,
        line: line,
        prefix: prefix
    )
}

public func LogErrorOnce(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) {
    guard !LogOnceLoggedMessages.contains(message) else {
        return
    }
    LogOnceLoggedMessages.insert(message)
    LogError(
        message,
        file: file,
        function: function,
        line: line
    )
}
