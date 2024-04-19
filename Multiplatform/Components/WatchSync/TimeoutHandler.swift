//
//  TimeoutHandler.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2023-09-22.
//

import Foundation
import EPWatchCore

@MainActor
class TimeoutHandler {

    private var timeoutTimer: DispatchSourceTimer?

    func set(
        timeout: DispatchTimeInterval,
        handler: @escaping () -> Void
    ) {
        if timeoutTimer != nil {
            timeoutTimer?.cancel()
        }
        let timerSource = DispatchSource.makeTimerSource(queue: .global())
        timerSource.schedule(
            deadline: .now() + timeout,
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
        timerSource.setEventHandler { [weak self] in
            Task {
                self?.timeoutTimer?.cancel()
                self?.timeoutTimer = nil
                handler()
            }
        }
        timeoutTimer = timerSource
        timerSource.resume()
    }

    func fireNow() {
        timeoutTimer?.schedule(
            deadline: .now(),
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
    }

    func cancel() {
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }
}
