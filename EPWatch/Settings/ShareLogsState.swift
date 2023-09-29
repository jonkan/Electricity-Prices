//
//  ShareLogsState.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation
import WatchConnectivity
import EPWatchCore

@MainActor
class ShareLogsState: NSObject, ObservableObject {

    static let shared: ShareLogsState = .init()

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

    enum StateMachine: Equatable {
        case ready
        case waitingForWatchSessionActivation
        case waitingForWatchToSendLogs(count: LogCount)
        case processingLogs(includingWatchLogs: Bool)

        var localizedDescription: String {
            description.localized
        }

        private var description: String {
            switch self {
            case .ready:
                return "Ready"
            case .waitingForWatchSessionActivation:
                return "Waiting for the watch to respond"
            case .waitingForWatchToSendLogs(let count):
                if count.total != nil || count.received > 0 {
                    return "Transfering logs from the watch"
                } else {
                    return "Waiting for the watch to send logs"
                }
            case .processingLogs:
                return "Processing logs"
            }
        }
    }

    @Published var state: StateMachine = .ready {
        didSet {
            Log("State did change: \(state)")
        }
    }
    @Published var fetchingWatchLogsError: Error? {
        didSet {
            if let error = fetchingWatchLogsError {
                LogError(error)
            }
        }
    }
    @Published var didFetchWatchLogs: Bool = false

    private var logsTempDirectoryURL = FileManager.default.temporaryDirectory
        .appending(path: "logs", directoryHint: .isDirectory)

    private var logsToShareContinuation: CheckedContinuation<[URL], Error>?

    private let timeoutHandler = TimeoutHandler()

    private override init() {}

    func fetchLogs() async throws -> [URL] {
        guard state == .ready else {
            throw NSError(0, "Sync already in progress")
        }
        fetchingWatchLogsError = nil
        didFetchWatchLogs = false
        // Remove any previous temp directory
        try? FileManager.default.removeItem(at: logsTempDirectoryURL)
        // Create the temp directory
        try FileManager.default.createDirectory(
            at: logsTempDirectoryURL,
            withIntermediateDirectories: true
        )
        return try await withCheckedThrowingContinuation { continuation in
            self.logsToShareContinuation = continuation

            if WCSession.isSupported() {
                WCSession.default.delegate = self

                state = .waitingForWatchSessionActivation
                timeoutHandler.set(timeout: .seconds(5)) {
                    self.fetchingWatchLogsError = NSError(0, "Timeout waiting for watch session activation")
                    self.processLogs(includingWatchLogs: false)
                }

                if WCSession.default.activationState == .activated {
                    session(WCSession.default, activationDidCompleteWith: WCSession.default.activationState, error: nil)
                } else {
                    WCSession.default.activate()
                }
            } else {
                Log("WCSession not supported")
                processLogs(includingWatchLogs: false)
            }
        }
    }

    private func processLogs(includingWatchLogs: Bool) {
        Task {
            state = .processingLogs(includingWatchLogs: false)
            guard let logsToShareContinuation = logsToShareContinuation else {
                LogError("Unexpected: No logsToShareCompletion")
                return
            }
            do {
                // Copy host logs to the temp directory
                let logsDirectory = FileManager.default.logFilesDirectory()
                let logFileURLs = try FileManager.default
                    .contentsOfDirectory(
                        at: logsDirectory,
                        includingPropertiesForKeys: nil
                    )
                    .filter({ $0.isFileURL && $0.pathExtension == "log" })

                for logFileURL in logFileURLs {
                    let destinationURL = logsTempDirectoryURL
                        .appending(path: logFileURL.lastPathComponent)
                    try FileManager.default.copyItem(at: logFileURL, to: destinationURL)
                }

                let logsToShare = try FileManager.default.contentsOfDirectory(
                    at: logsTempDirectoryURL,
                    includingPropertiesForKeys: nil
                )
                    .filter({ $0.isFileURL && $0.pathExtension == "log" })

                logsToShareContinuation.resume(returning: logsToShare)
            } catch {
                logsToShareContinuation.resume(throwing: error)
            }
            state = .ready
            didFetchWatchLogs = includingWatchLogs
        }
    }

}

extension ShareLogsState: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task {
            Log("Session activation state: \(activationState.description)")
            timeoutHandler.cancel()
            guard state == .waitingForWatchSessionActivation else {
                Log("State not .waitingForWatchSessionActivation")
                processLogs(includingWatchLogs: false)
                return
            }
            guard activationState == .activated else {
                processLogs(includingWatchLogs: false)
                return
            }
            guard WCSession.default.isWatchAppInstalled else {
                Log("Watch app not installed")
                processLogs(includingWatchLogs: false)
                return
            }
            guard WCSession.default.isReachable else {
                fetchingWatchLogsError = NSError(0, "Watch not reachable")
                processLogs(includingWatchLogs: false)
                return
            }
            state = .waitingForWatchToSendLogs(count: .init(total: nil, received: 0))
            timeoutHandler.set(timeout: .seconds(5)) {
                self.fetchingWatchLogsError = NSError(0, "Timeout waiting for message reply")
                self.processLogs(includingWatchLogs: false)
            }
            session.sendMessage(["sendLogs": true]) { reply in
                Task {
                    Log("Did receive message reply \(reply)")
                    guard case .waitingForWatchToSendLogs(var count) = self.state else {
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
                    self.state = .waitingForWatchToSendLogs(count: count)
                    self.timeoutHandler.set(timeout: .seconds(10)) {
                        self.fetchingWatchLogsError = NSError(0, "Timeout waiting for watch file transfers \(count.description)")
                        self.processLogs(includingWatchLogs: false)
                    }
                }
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Task {
            Log("Session did become inactive")
            guard state == .waitingForWatchSessionActivation else {
                return
            }
            timeoutHandler.fireNow()
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Task {
            Log("Session did deactivate")
            guard state == .waitingForWatchSessionActivation else {
                return
            }
            timeoutHandler.fireNow()
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // The file needs to be copied synchronously, otherwise it might already be deleted.
        Log("Did receive file: \(file.fileURL.lastPathComponent)")
        do {
            let destinationURL = logsTempDirectoryURL.appending(path: file.fileURL.lastPathComponent)
            try FileManager.default.copyItem(at: file.fileURL, to: destinationURL)
        } catch {
            LogError(error)
        }
        Task {
            guard case .waitingForWatchToSendLogs(var count) = state else {
                LogError("Unexpected state not .waitingForWatchToSendLogs")
                return
            }
            timeoutHandler.cancel()

            count.received = count.received + 1
            if let total = count.total, total <= count.received {
                processLogs(includingWatchLogs: true)
            } else {
                state = .waitingForWatchToSendLogs(count: count)
                timeoutHandler.set(timeout: .seconds(10)) {
                    self.fetchingWatchLogsError = NSError(0, "Timeout waiting for watch file transfers \(count.description)")
                    self.processLogs(includingWatchLogs: true)
                }
            }
        }
    }

}

extension ShareLogsState {
    static let mocked: ShareLogsState = {
        let s = ShareLogsState()
        s.didFetchWatchLogs = true
        return s
    }()

    static let mockedInProgress: ShareLogsState = {
        let s = ShareLogsState()
        s.state = .waitingForWatchToSendLogs(count: .init(total: 2, received: 1))
        return s
    }()

    static let mockedWithError: ShareLogsState = {
        let s = ShareLogsState()
        s.fetchingWatchLogsError = NSError(0, "Some error")
        return s
    }()
}
