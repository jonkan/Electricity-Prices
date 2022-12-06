//
//  SessionManager.swift
//
//
//  Created by Jonas Bromö on 2022-12-05.
//

import Foundation
import SwiftUI

public class SessionManager: NSObject {

    struct TaskResponse {
        let data: Data
        let httpResponse: HTTPURLResponse
    }

    public static let shared = SessionManager()
    public let identifier = "SessionManager"

    private let config: URLSessionConfiguration
    private lazy var session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    private var taskContinuations = TaskContinuations()

    private override init() {
        config = URLSessionConfiguration.background(
            withIdentifier: identifier
        )
        config.sessionSendsLaunchEvents = true
    }

    /// Performs a download request, first as a data task (a foreground networking task), then
    /// if the data task is cancelled by the system from not finishing in time, the request is retried
    /// as a download task (a background networking task). The retried request should automatically be
    /// deduplicated by the system, see:
    /// - https://developer.apple.com/videos/play/wwdc2022/10142/?time=618
    /// - https://developer.apple.com/forums/thread/709437
    ///
    /// - Parameter request: The request to download
    /// - Returns: The downloaded data and url response
    func download(_ request: URLRequest) async throws -> TaskResponse {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                let task = session.dataTask(with: request)
                let taskContinuation = TaskContinuation(
                    taskIdentifier: task.taskIdentifier,
                    continuation: continuation
                )
                await taskContinuations.insert(taskContinuation)
                task.resume()
            }
        }
    }

}

extension SessionManager: URLSessionDelegate {

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        Log("Task did complete: \(error?.urlErrorDescription ?? "no error")")
        Task {
            guard let taskContinuation = await taskContinuations[task.taskIdentifier] else {
                LogError("Unable to find task continuation")
                return
            }
            do {
                if let error = error {
                    if error.urlErrorCode == NSURLErrorCancelled {
                        guard let request = task.currentRequest else {
                            throw NSError(0, "No task request to retry")
                        }
                        Log("Retrying cancelled data task as a download task")
                        let retryTask = session.downloadTask(with: request)
                        let retryTaskContinuation = await TaskContinuation(
                            taskIdentifier: retryTask.taskIdentifier,
                            retrying: taskContinuation
                        )
                        await taskContinuations.remove(taskContinuation)
                        await taskContinuations.insert(retryTaskContinuation)
                        retryTask.resume()
                    } else {
                        throw error
                    }
                } else if let response = task.response as? HTTPURLResponse {
                    await taskContinuation.resume(returningDataWith: response)
                } else {
                    throw NSError(0, "Unexpected data task, missing http response")
                }
            } catch {
                await taskContinuation.resume(throwing: error)
            }
        }
    }

}

extension SessionManager: URLSessionDataDelegate {

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        Log("Data task did receive \(data.isEmpty ? "no data" : "data")")
        Task {
            await taskContinuations[dataTask.taskIdentifier]?.appendData(data)
        }
    }

}

extension SessionManager: URLSessionDownloadDelegate {

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        Log("Download task did complete")
        Task {
            guard let taskContinuation = await taskContinuations[downloadTask.taskIdentifier] else {
                LogError("Unable to find task continuation")
                return
            }
            do {
                guard let response = downloadTask.response as? HTTPURLResponse else {
                    throw NSError(0, "Unexpected download task, missing http response")
                }
                let data = try Data(contentsOf: location)
                await taskContinuation.setData(data)
                await taskContinuation.resume(returningDataWith: response)
            } catch {
                await taskContinuation.resume(throwing: error)
            }
        }
    }

}

// MARK: - Helpers

private actor TaskContinuation {

    var taskIdentifier: Int
    private var continuation: CheckedContinuation<SessionManager.TaskResponse, Error>
    private var data: Data = Data()

    init(taskIdentifier: Int, continuation: CheckedContinuation<SessionManager.TaskResponse, Error>) {
        self.taskIdentifier = taskIdentifier
        self.continuation = continuation
    }

    init(taskIdentifier: Int, retrying continuation: TaskContinuation) async {
        self.taskIdentifier = taskIdentifier
        self.continuation = await continuation.continuation
    }

    func appendData(_ other: Data) {
        data.append(other)
    }

    func setData(_ other: Data) {
        data = other
    }

    func resume(returningDataWith response: HTTPURLResponse) {
        continuation.resume(returning: .init(data: data, httpResponse: response))
    }

    func resume(throwing error: Error) {
        continuation.resume(throwing: error)
    }
}

private actor TaskContinuations {
    private var continuations: [Int: TaskContinuation] = [:]

    subscript(_ id: Int) -> TaskContinuation? {
        return continuations[id]
    }

    func insert(_ continuation: TaskContinuation) async {
        await continuations[continuation.taskIdentifier] = continuation
    }

    func remove(_ continuation: TaskContinuation) async {
        await continuations[continuation.taskIdentifier] = nil
    }
}
