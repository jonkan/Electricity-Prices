//
//  LogOnce.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation

private var LogOnceLoggedMessages = Set<String>()

public func LogOnce(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    level: LogLevel = .debug
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
        level: level
    )
}

public func LogErrorOnce(
    _ message: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
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
