//
//  HostCommunicationManager.swift
//  EPWatchKitApp
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation
import WatchConnectivity
import EPWatchCore

class HostCommunicationManager: NSObject, ObservableObject {

    static let shared: HostCommunicationManager = .init()

    @Published var logFilesTransferProgress: Progress?

    private override init() {
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendLogs() throws -> [String] {
        let logsDirectory = FileManager.default.logFilesDirectory()
        let logFileURLs = try FileManager.default
            .contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: nil
            )
            .filter({ $0.isFileURL && $0.pathExtension == "log" })

        // Cancel any previous transfers
        WCSession.default.outstandingFileTransfers.forEach({ $0.cancel() })

        for logFileURL in logFileURLs {
            let logFileName = logFileURL.lastPathComponent
            let existing = WCSession.default.outstandingFileTransfers
            guard !existing.contains(where: { $0.file.fileURL == logFileURL }) else {
                Log("Transfer already in progress for: \(logFileName)")
                continue
            }
            Log("Starting file transfer for: \(logFileName)")
            WCSession.default.transferFile(logFileURL, metadata: nil)
        }

        let children = WCSession.default.outstandingFileTransfers.map({ $0.progress })
        let overallProgress = Progress(totalUnitCount: Int64(children.count))
        children.forEach({ overallProgress.addChild($0, withPendingUnitCount: 1) })
        Task {
            logFilesTransferProgress = overallProgress
        }

        return logFileURLs.map({ $0.lastPathComponent })
    }

}

extension HostCommunicationManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Log("Session activation state: \(activationState.description)")
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        Log("Did receive message: \(message)")
        if message.keys.contains("sendLogs") {
            do {
                let logFileNames = try sendLogs()
                replyHandler(["logs": logFileNames])
            } catch {
                LogError(error)
                replyHandler(["error": error])
            }
        } else if message.keys.contains("cancelFileTransfers") {
            let transfers = WCSession.default.outstandingFileTransfers
            if !transfers.isEmpty {
                Log("Cancelling \(transfers.count) transfers")
                transfers.forEach({ $0.cancel() })
            }
        }
    }

}
