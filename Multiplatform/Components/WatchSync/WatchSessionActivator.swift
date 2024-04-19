//
//  WatchSessionActivator.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2023-09-22.
//

import Foundation
import WatchConnectivity
import EPWatchCore

@MainActor
class WatchSessionActivator: NSObject, ObservableObject {

    enum ActivationError: Error {
        case timeoutWaitingForWatchSessionActivation
        case watchSessionNotSupported
        case watchAppNotInstalled
        case watchNotReachable
    }

    private var activationContinuation: CheckedContinuation<Void, Error>?
    private let timeoutHandler = TimeoutHandler()

    func activate() async throws {
        guard activationContinuation == nil else {
            throw NSError(0, "Activation already in progress")
        }

        try await withCheckedThrowingContinuation { continuation in
            self.activationContinuation = continuation

            guard WCSession.isSupported() else {
                resume(throwing: .watchSessionNotSupported)
                return
            }
            WCSession.default.delegate = self

            timeoutHandler.set(timeout: .seconds(5)) {
                self.resume(throwing: .timeoutWaitingForWatchSessionActivation)
            }

            if WCSession.default.activationState == .activated {
                session(WCSession.default, activationDidCompleteWith: WCSession.default.activationState, error: nil)
            } else {
                WCSession.default.activate()
            }
        }
    }

    private func resume(throwing error: ActivationError? = nil) {
        Task {
            guard let activationContinuation = activationContinuation else {
                LogError("Unexpected: No activationContinuation")
                return
            }
            if let error = error {
                activationContinuation.resume(throwing: error)
            } else {
                activationContinuation.resume()
            }
            self.activationContinuation = nil
            WCSession.default.delegate = nil
        }
    }

}

extension WatchSessionActivator: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task {
            Log("Session activation state: \(activationState.description)")
            timeoutHandler.cancel()
            guard activationState == .activated else {
                resume()
                return
            }
            guard WCSession.default.isWatchAppInstalled else {
                resume(throwing: .watchAppNotInstalled)
                return
            }
            guard WCSession.default.isReachable else {
                resume(throwing: .watchNotReachable)
                return
            }
            resume()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Task {
            Log("Session did become inactive")
            timeoutHandler.fireNow()
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Task {
            Log("Session did deactivate")
            timeoutHandler.fireNow()
        }
    }

}
