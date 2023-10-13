//
//  ShareLogsState.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation
import WatchConnectivity
import EPWatchCore
import SwiftUI
import Combine

@MainActor
class ShareLogsState: ObservableObject {

    static let logsTempDirectoryURL = FileManager.default.temporaryDirectory
        .appending(path: "logs", directoryHint: .isDirectory)

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
        case syncing
        case processingLogs

        var localizedDescription: String {
            description.localized
        }

        private var description: String {
            switch self {
            case .ready:
                return "Ready"
            case .syncing:
                return "Waiting for the watch to send logs"
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
    var syncState: WatchSyncManager.SyncState {
        watchSyncManager.syncState
    }
    @Published var fetchingWatchLogsError: Error? {
        didSet {
            if let error = fetchingWatchLogsError {
                LogError(error)
            }
        }
    }
    @Published var didFetchWatchLogs: Bool = false

    private let watchSyncManager: WatchSyncManager

    private var logsToShareContinuation: CheckedContinuation<[URL], Error>?

    private let timeoutHandler = TimeoutHandler()

    private var cancellable: AnyCancellable?

    init(watchSyncManager: WatchSyncManager) {
        self.watchSyncManager = watchSyncManager

        cancellable = watchSyncManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func fetchLogs() async throws -> [URL] {
        guard state == .ready else {
            throw NSError(0, "Sync already in progress")
        }
        fetchingWatchLogsError = nil
        didFetchWatchLogs = false
        // Remove any previous temp directory
        try? FileManager.default.removeItem(at: Self.logsTempDirectoryURL)
        // Create the temp directory
        try FileManager.default.createDirectory(
            at: Self.logsTempDirectoryURL,
            withIntermediateDirectories: true
        )

        do {
            state = .syncing
            try await watchSyncManager.fetchWatchLogs()
            didFetchWatchLogs = true
        } catch {
            fetchingWatchLogsError = error
        }

        defer {
            state = .ready
        }
        do {
            return try await processLogs()
        } catch {
            fetchingWatchLogsError = error
        }
        return []
    }

    private func processLogs() async throws -> [URL] {
        state = .processingLogs

        // Copy host logs to the temp directory
        let logsDirectory = FileManager.default.logFilesDirectory()
        let logFileURLs = try FileManager.default
            .contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: nil
            )
            .filter({ $0.isFileURL && $0.pathExtension == "log" })

        for logFileURL in logFileURLs {
            let destinationURL = Self.logsTempDirectoryURL
                .appending(path: logFileURL.lastPathComponent)
            try FileManager.default.copyItem(at: logFileURL, to: destinationURL)
        }

        let logsToShare = try FileManager.default.contentsOfDirectory(
            at: Self.logsTempDirectoryURL,
            includingPropertiesForKeys: nil
        )
            .filter({ $0.isFileURL && $0.pathExtension == "log" })

        return logsToShare
    }

}

extension ShareLogsState {
    static let mocked: ShareLogsState = {
        let s = ShareLogsState(watchSyncManager: .mocked)
        s.didFetchWatchLogs = true
        return s
    }()

    static let mockedInProgress: ShareLogsState = {
        let s = ShareLogsState(watchSyncManager: .mocked)
        s.state = .syncing

        return s
    }()

    static let mockedWithError: ShareLogsState = {
        let s = ShareLogsState(watchSyncManager: .mocked)
        s.fetchingWatchLogsError = NSError(0, "Some error")
        return s
    }()
}
