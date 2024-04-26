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

// swiftlint:disable type_body_length file_length
@MainActor
class WatchSyncManager: NSObject, ObservableObject {

    struct LogCount: Equatable {
        var total: Int?
        var received: Int

        var description: String {
            if let total = total {
                return "\(received)/\(total)"
            } else {
                return "\(received)/nil"
            }
        }
    }

    enum SyncState: Equatable {
        case notReady
        case ready
        case waitingForWatchToSendLogs(count: LogCount)

        var localizedDescription: String {
            description
        }

        private var description: String {
            switch self {
            case .notReady:
                String(localized: "Not ready")
            case .ready:
                String(localized: "Ready")
            case .waitingForWatchToSendLogs(let count):
                if count.total != nil || count.received > 0 {
                    String(localized: "Transfering logs from the watch")
                } else {
                    String(localized: "Waiting for the watch to send logs")
                }
            }
        }
    }

    enum SyncError: Error, Equatable {
        case timeoutWaitingForWatchSessionActivation
        case watchSessionNotSupported
        case watchAppNotInstalled
        case watchNotReachable
        case watchActivationFailed
        case timeoutWaitingForMessageReply
        case timeoutWaitingForWatchFileTransfers(_ message: String)
        case other(_ error: String)

        var localizedDescription: String {
            description
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
            case .timeoutWaitingForMessageReply:
                "Timeout waiting for message reply"
            case .timeoutWaitingForWatchFileTransfers(let message):
                "Timeout waiting for watch file transfers \(message)"
            case .other(let error):
                error
            }
        }
    }

    var isSyncSupported: Bool {
        WCSession.isSupported() &&
        WCSession.default.activationState == .activated &&
        WCSession.default.isWatchAppInstalled
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
            Log("Did change: \(syncState)")
        }
    }
    @Published private(set) var syncError: SyncError?

    private var appState: AppState
    private var appStateWillChangeCancellable: AnyCancellable?
    private var lastReceivedAppStateDTO: AppStateDTO?

    private var activationContinuation: CheckedContinuation<Void, Error>?
    private var fetchWatchLogsContinuation: CheckedContinuation<Void, Error>?
    private let timeoutHandler = TimeoutHandler()

    private enum SyncTask {
        case syncAppContext
        case fetchWatchLogs(_ continuation: CheckedContinuation<Void, Error>)
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

    func fetchWatchLogs() async throws {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                await syncTaskChannel.send(.fetchWatchLogs(continuation))
            }
        }
    }

    private func queueSyncTask(_ task: SyncTask) {
        Task {
            await syncTaskChannel.send(task)
        }
    }

    private func handleSyncTaskChannel() {
        Task {
            for try await task in syncTaskChannel.debounce(for: .milliseconds(250)) {
                assert(!isSyncing, "Sync already in progress")
                isSyncing = true
                do {
                    switch task {
                    case .syncAppContext:
                        try await activate()
                        try await syncAppContext()
                    case let .fetchWatchLogs(continuation):
                        do {
                            try await activate()
                        } catch {
                            continuation.resume(throwing: error)
                            throw error
                        }
                        try await fetchWatchLogs(continuation)
                    }
                    syncError = nil
                } catch let error as SyncError {
                    syncError = error
                } catch {
                    syncError = .other(error.localizedDescription)
                }

                if let syncError, syncError != .watchSessionNotSupported {
                    LogError(syncError)
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
                if syncState == .notReady {
                    syncState = .ready
                }
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
        if appStateDTO != lastReceivedAppStateDTO {
            let context = try appStateDTO.encodeToApplicationContext()
            try WCSession.default.updateApplicationContext(context)
            lastReceivedAppStateDTO = nil
            Log("Success updating application context")
        } else {
            Log("App state not changed since last received, skipping sync")
        }
        hasUnsyncedAppContextChanges = false
    }

    private func fetchWatchLogs(_ continuation: CheckedContinuation<Void, Error>) async throws {
        guard fetchWatchLogsContinuation == nil else {
            throw SyncError.other("Fetch watch logs already in progress")
        }
        fetchWatchLogsContinuation = continuation

        guard syncState == .ready else {
            resumeFetchWatchLogs(
                throwing: .other("Unable to fetch logs from watch, state not ready")
            )
            return
        }
        guard WCSession.default.isReachable else {
            resumeFetchWatchLogs(throwing: .watchNotReachable)
            return
        }
        syncState = .waitingForWatchToSendLogs(count: .init(total: nil, received: 0))
        timeoutHandler.set(timeout: .seconds(5)) {
            self.resumeFetchWatchLogs(throwing: .timeoutWaitingForMessageReply)
        }

        WCSession.default.sendMessage(["sendLogs": true]) { reply in
            Task {
                Log("Did receive message reply \(reply)")
                guard case .waitingForWatchToSendLogs(var count) = self.syncState else {
                    Log("State not .waitingForWatchToSendLogs")
                    return
                }
                guard let logs = reply["logs"] as? [String] else {
                    LogError("Unexpected reply")
                    self.timeoutHandler.fireNow()
                    return
                }
                count.total = logs.count
                Log("Watch will send \(logs.count) logs (\(count.received) already received)")
                self.syncState = .waitingForWatchToSendLogs(count: count)
                self.timeoutHandler.set(timeout: .seconds(10)) {
                    self.resumeFetchWatchLogs(throwing: .timeoutWaitingForWatchFileTransfers(count.description))
                }
            }
        }
    }

    private func resumeFetchWatchLogs(throwing error: SyncError? = nil) {
        Task {
            if let error = error {
                syncState = .notReady
                fetchWatchLogsContinuation?.resume(throwing: error)
            } else {
                syncState = .ready
                fetchWatchLogsContinuation?.resume()
            }
            fetchWatchLogsContinuation = nil
        }
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

            guard activationState == .activated  else {
                resumeActivation(throwing: .watchActivationFailed)
                return
            }
            guard session.isWatchAppInstalled else {
                resumeActivation(throwing: .watchAppNotInstalled)
                return
            }
            resumeActivation()
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

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
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
                lastReceivedAppStateDTO = appStateDTO
                appState.update(from: appStateDTO)
                Log("Success updating app state")
            } catch {
                LogError("Failed to update app state: \(error)")
            }
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // The file needs to be copied synchronously, otherwise it might already be deleted.
        Log("Did receive file: \(file.fileURL.lastPathComponent)")
        do {
            let destinationURL = ShareLogsState.logsTempDirectoryURL
                .appending(path: file.fileURL.lastPathComponent)
            try FileManager.default.copyItem(at: file.fileURL, to: destinationURL)
        } catch {
            LogError(error)
        }
        Task {
            guard case .waitingForWatchToSendLogs(var count) = syncState else {
                LogError("Unexpected state not .waitingForWatchToSendLogs")
                return
            }
            timeoutHandler.cancel()

            count.received += 1
            if let total = count.total, total <= count.received {
                resumeFetchWatchLogs()
            } else {
                syncState = .waitingForWatchToSendLogs(count: count)
                timeoutHandler.set(timeout: .seconds(10)) {
                    self.resumeFetchWatchLogs(throwing: .timeoutWaitingForWatchFileTransfers(count.description))
                }
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
