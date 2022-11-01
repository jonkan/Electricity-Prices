//
//  SupportSettingsView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-10-31.
//

import SwiftUI
import ActivityView
import EPWatchCore

struct SupportSettingsView: View {

    @EnvironmentObject private var shareLogsState: ShareLogsState
    @State private var logURLs: [URL]?
    @State private var logsActivityItem: ActivityItem?
    @State private var isEmailCopied: Bool = false
    private let supportEmail = "support@j0nas.se"

    var body: some View {
        List {
            Section {
                Group {
                    Text("Please report any issues to ") +
                    Text(verbatim: supportEmail)
                        .foregroundColor(.accentColor)
                }
                .onTapGesture {
                    UIPasteboard.general.url = URL(string: supportEmail)
                    isEmailCopied = true
                }
            } footer: {
                if isEmailCopied {
                    Text("Email adress copied!")
                } else {
                    Text("Tap to copy the email address")
                }
            }
            Section {
                VStack(alignment: .leading) {
                    HStack(spacing: 12) {
                        if shareLogsState.state != .ready {
                            if case .waitingForWatchToSendLogs(let count) = shareLogsState.state, let count = count {
                                CircularProgressView(
                                    progress: Double(count.received) / Double(count.total)
                                )
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text(shareLogsState.state.localizedDescription)
                        } else {
                            Text("\(logURLs?.count ?? 0) log files")
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button("Share") {
                        logsActivityItem = ActivityItem(itemsArray: logURLs ?? [])
                    }
                    .disabled(logURLs == nil)
                    Spacer()
                }
            } header: {
                Text("Logs")
            }
        }
        .activitySheet($logsActivityItem)
        .onAppear {
            Task {
                do {
                    logURLs = try await shareLogsState.shareLogs()
                } catch {
                    LogError(error)
                }
            }
        }
    }

}

struct SupportSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SupportSettingsView()
            .environmentObject(ShareLogsState.mockedInProgress)
    }
}

