//
//  WatchSyncManager.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2023-09-29.
//

import Foundation
import EPWatchCore
import Combine
import WatchConnectivity
import AsyncAlgorithms
import SwiftUI

@MainActor
class WatchSyncManager: NSObject, ObservableObject {

    enum SyncState {
        case notReady
        case ready

        var localizedDescription: String {
            description.localized
        }

        private var description: String {
            switch self {
            case .notReady:
                "Not ready"
            case .ready:
                "Ready"
            }
        }
    }

    enum SyncError: Error {
        case timeoutWaitingForWatchSessionActivation
        case watchSessionNotSupported
        case watchAppNotInstalled
        case watchNotReachable
        case watchActivationFailed
        case other(_ errorMessage: String)

        var localizedDescription: String {
            description.localized
        }

        private var description: String {
            switch self {
            case .timeoutWaitingForWatchSessionActivation:
                "Timeout waiting for the watch to respond"
            case .watchSessionNotSupported:
                "No watch"
            case .watchAppNotInstalled:
                "Watch app not installed"
            case .watchNotReachable:
                "Watch not reachable"
            case .watchActivationFailed:
                "Watch not reacable (unknown)"
            case .other(let errorMessage):
                errorMessage
            }
        }
    }

    var isSyncSupported: Bool {
        WCSession.isSupported() && WCSession.default.isWatchAppInstalled
    }
    @AppStorage("isSyncWithWatchEnabled")
    public var isAppContextSyncEnabled: Bool = true {
        didSet {
            if !oldValue && isAppContextSyncEnabled {
                syncAppContext()
            }
        }
    }

    @Published var hasUnsyncedAppContextChanges: Bool = true
    @Published var isSyncing: Bool = false

    @Published var syncState: SyncState = .notReady {
        didSet {
            Log("State did change: \(syncState)")
        }
    }
    @Published var syncError: Error? {
        didSet {
            if let error = syncError {
                LogError(error)
            }
        }
    }

    private var appState: AppState
    private var appStateWillChangeCancellable: AnyCancellable?

    private var activationContinuation: CheckedContinuation<Void, Error>?
    private let timeoutHandler = TimeoutHandler()

    private enum SyncTask {
        case syncAppContext
        case fetchWatchLogs
    }
    private var syncTaskChannel = AsyncChannel<SyncTask>()

    init(appState: AppState) {
        self.appState = appState
        super.init()

        handleSyncTaskChannel()

        // Listen to app state changes
        appStateWillChangeCancellable = appState.objectWillChange
            .map { [weak self] in
                Task {
                    self?.hasUnsyncedAppContextChanges = true
                }
                return $0
            }
            .debounce(for: .seconds(5), scheduler: DispatchQueue.global())
            .sink { [weak self] _ in
                self?.queueSyncTask(.syncAppContext)
            }

        syncAppContext()
    }

    func syncAppContext() {
        Task {
            await syncTaskChannel.send(.syncAppContext)
        }
    }

    private func queueSyncTask(_ task: SyncTask) {
        Task {
            await syncTaskChannel.send(task)
        }
    }

    private func handleSyncTaskChannel() {
        Task {
            for try await task in syncTaskChannel.debounce(for: .milliseconds(250))  {
                assert(!isSyncing, "Sync already in progress")
                isSyncing = true
                do {
                    switch task {
                    case .syncAppContext:
                        try await activate()
                        try await syncAppContext()
                    case .fetchWatchLogs:
                        try await activate()
                        // TODO: fetch logs
                    }
                    syncError = nil
                } catch {
                    syncError = error
                }
                isSyncing = false
            }
        }
    }

    private func activate() async throws {
        guard activationContinuation == nil else {
            throw SyncError.other("Activation already in progress")
        }
        try await withCheckedThrowingContinuation { continuation in
            self.activationContinuation = continuation

            guard WCSession.isSupported() else {
                resumeActivation(throwing: .watchSessionNotSupported)
                return
            }
            WCSession.default.delegate = self

            if WCSession.default.activationState == .activated {
                session(WCSession.default, activationDidCompleteWith: .activated, error: nil)
            } else {
                timeoutHandler.set(timeout: .seconds(5)) {
                    self.resumeActivation(throwing: .timeoutWaitingForWatchSessionActivation)
                }
                WCSession.default.activate()
            }
        }
    }

    private func resumeActivation(throwing error: SyncError? = nil) {
        Task {
            if let error = error {
                syncState = .notReady
                activationContinuation?.resume(throwing: error)
            } else {
                syncState = .ready
                activationContinuation?.resume()
            }
            activationContinuation = nil
        }
    }

    private func syncAppContext() async throws {
        guard syncState == .ready else {
            throw SyncError.other("Unable to start sync, state not ready")
        }
        guard isAppContextSyncEnabled else {
            hasUnsyncedAppContextChanges = false
            return
        }
        let appStateDTO = appState.toDTO()
        let receivedAppStateDTO = try? AppStateDTO.decode(from: WCSession.default.receivedApplicationContext)
        if appStateDTO != receivedAppStateDTO {
            let context = try appStateDTO.encodeToApplicationContext()
            try WCSession.default.updateApplicationContext(context)
            Log("Success updating application context")
        } else {
            Log("App state not changed since last received, skipping sync")
        }
        hasUnsyncedAppContextChanges = false
    }

}

extension WatchSyncManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task {
            Log("Session activation state: \(activationState.description)")
            timeoutHandler.cancel()

            if activationState == .activated {
                resumeActivation()
            } else if !WCSession.default.isWatchAppInstalled {
                resumeActivation(throwing: .watchAppNotInstalled)
            } else {
                resumeActivation(throwing: .watchActivationFailed)
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Task {
            Log("Session did become inactive")
            timeoutHandler.fireNow()
            syncState = .notReady
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Task {
            Log("Session did deactivate")
            timeoutHandler.fireNow()
            syncState = .notReady
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task {
            guard isAppContextSyncEnabled else {
                Log("Session did receive application context (sync disabled)")
                return
            }
            Log("Session did receive application context")
            do {
                guard let appStateDTO = try AppStateDTO.decode(from: applicationContext) else {
                    throw NSError(0, "Missing appStateDTO from applicationContext")
                }
                appState.update(from: appStateDTO)
                Log("Success updating app state")
            } catch {
                LogError("Failed to update app state: \(error)")
            }
        }
    }

}

extension WatchSyncManager {
    static let mocked: WatchSyncManager = {
        let w = WatchSyncManager(appState: .mocked)
        return w
    }()
}
