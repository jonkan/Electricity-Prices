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
        var total: Int
        var received: Int
    }

    enum StateMachine: Equatable {
        case ready
        case waitingForWatchSessionActivation
        case waitingForWatchToSendLogs(count: LogCount?)
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
                if count != nil {
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

    private var logsToShareCompletion: CheckedContinuation<[URL], Error>?

    private override init() {}

    func fetchLogs() async throws -> [URL] {
        guard state == .ready else {
            throw NSError(0, "Sharing logs already in progress")
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
            self.logsToShareCompletion = continuation

            if WCSession.isSupported() {
                WCSession.default.delegate = self

                state = .waitingForWatchSessionActivation
                setTimeoutHandler(.seconds(5)) {
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

    func processLogs(includingWatchLogs: Bool) {
        Task {
            state = .processingLogs(includingWatchLogs: false)
            guard let logsToShareCompletion = logsToShareCompletion else {
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

                logsToShareCompletion.resume(returning: logsToShare)
            } catch {
                logsToShareCompletion.resume(throwing: error)
            }
            state = .ready
            didFetchWatchLogs = includingWatchLogs
        }
    }

    private var timeoutTimer : DispatchSourceTimer?
    private func setTimeoutHandler(
        _ timeout: DispatchTimeInterval,
        handler: @escaping () -> Void
    ) {
        Log("Start waiting for watch timer: \(timeout)")
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

    private func fireTimeoutHandler() {
        timeoutTimer?.schedule(
            deadline: .now(),
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
    }

    private func stopTimeoutHandler() {
        Log("Stop waiting for watch timer")
        timeoutTimer?.cancel()
        timeoutTimer = nil
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
            stopTimeoutHandler()
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
            state = .waitingForWatchToSendLogs(count: nil)
            setTimeoutHandler(.seconds(30)) {
                self.fetchingWatchLogsError = NSError(0, "Timeout waiting for message reply")
                self.processLogs(includingWatchLogs: false)
            }
            session.sendMessage(["sendLogs": true]) { reply in
                Task {
                    Log("Did receive message reply \(reply)")
                    guard case .waitingForWatchToSendLogs = self.state else {
                        Log("State not .waitingForWatchToSendLogs")
                        return
                    }
                    guard let logs = reply["logs"] as? [String] else {
                        LogError("Unexpected reply")
                        self.fireTimeoutHandler()
                        return
                    }
                    Log("Watch will send \(logs.count) logs")
                    self.state = .waitingForWatchToSendLogs(count: .init(total: logs.count, received: 0))
                    self.setTimeoutHandler(.seconds(90)) {
                        self.fetchingWatchLogsError = NSError(0, "Timeout waiting for watch file transfers 0/\(logs.count)")
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
            fireTimeoutHandler()
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Task {
            Log("Session did deactivate")
            guard state == .waitingForWatchSessionActivation else {
                return
            }
            fireTimeoutHandler()
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        Task {
            Log("Did receive file: \(file.fileURL.lastPathComponent)")
            guard case .waitingForWatchToSendLogs(let count) = state else {
                LogError("Unexpected state not .waitingForWatchToSendLogs")
                return
            }
            guard var count = count else {
                LogError("Unexpected, no count set")
                return
            }
            stopTimeoutHandler()
            do {
                let destinationURL = logsTempDirectoryURL.appending(path: file.fileURL.lastPathComponent)
                try FileManager.default.copyItem(at: file.fileURL, to: destinationURL)
            } catch {
                LogError(error)
            }
            count.received = count.received + 1
            if count.received >= count.total {
                processLogs(includingWatchLogs: true)
            } else {
                state = .waitingForWatchToSendLogs(count: count)
                setTimeoutHandler(.seconds(90)) {
                    self.fetchingWatchLogsError = NSError(0, "Timeout waiting for watch file transfers \(count.received)/\(count.total)")
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
