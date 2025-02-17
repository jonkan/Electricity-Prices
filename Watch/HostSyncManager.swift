//
//  HostSyncManager.swift
//  ElectricityPricesWatchApp
//
//  Created by Jonas Bromö on 2022-10-28.
//

import Foundation
import WatchConnectivity
import Core
import Combine

@MainActor
class HostSyncManager: NSObject, ObservableObject {

    @Published var logFilesTransferProgress: Progress?

    private var appState: AppState
    private var appStateWillChangeCancellable: AnyCancellable?
    private var lastReceivedAppStateDTO: AppStateDTO?

    init(appState: AppState) {
        self.appState = appState
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()

        appStateWillChangeCancellable = appState.objectWillChange
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] _ in
                self?.syncAppContext()
            }
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

        logFilesTransferProgress = overallProgress

        return logFileURLs.map({ $0.lastPathComponent })
    }

    private func syncAppContext() {
        do {
            let appStateDTO = appState.toDTO()
            if appStateDTO != lastReceivedAppStateDTO {
                let context = try appStateDTO.encodeToApplicationContext()
                try WCSession.default.updateApplicationContext(context)
                lastReceivedAppStateDTO = nil
                Log("Success updating application context")
            } else {
                Log("App state not changed since last received, skipping sync")
            }
        } catch {
            LogError(error)
        }
    }

}

extension HostSyncManager: @preconcurrency WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Log("Session activation state: \(activationState.description)")
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Log("Did receive message: \(message)")
        if message.keys.contains("sendLogs") {
            Task { @MainActor in
                do {
                    let logFileNames = try sendLogs()
                    replyHandler(["logs": logFileNames])
                } catch {
                    LogError(error)
                    replyHandler(["error": error])
                }
            }
        } else if message.keys.contains("cancelFileTransfers") {
            let transfers = WCSession.default.outstandingFileTransfers
            if !transfers.isEmpty {
                Log("Cancelling \(transfers.count) transfers")
                transfers.forEach({ $0.cancel() })
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Log("Session did receive application context")
        do {
            guard let appStateDTO = try AppStateDTO.decode(from: applicationContext) else {
                throw NSError(0, "Missing appStateDTO from applicationContext")
            }
            Task { @MainActor in
                lastReceivedAppStateDTO = appStateDTO
                appState.update(from: appStateDTO)
                Log("Success updating app state")
            }
        } catch {
            LogError("Failed to update app state: \(error)")
        }
    }

}
