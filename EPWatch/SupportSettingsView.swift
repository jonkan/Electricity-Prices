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
    @State private var acknowledgeEmailCopied: Bool = false
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
                    acknowledgeEmailCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        acknowledgeEmailCopied = false
                    }
                }
            } footer: {
                if acknowledgeEmailCopied {
                    Text("Email adress copied!")
                } else {
                    Text("Tap to copy the email address")
                }
            }
            Section {
                Label {
                    if shareLogsState.state != .ready {
                        Text(shareLogsState.state.localizedDescription)
                    } else {
                        Text("\(logURLs?.count ?? 0) log files")
                    }
                } icon: {
                    Group {
                        if case .waitingForWatchToSendLogs(let count) = shareLogsState.state,
                           let count = count {
                            CircularProgressView(
                                progress: Double(count.received) / Double(count.total)
                            )
                        } else if shareLogsState.state != .ready {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "doc.text")
                        }
                    }
                    .frame(width: 20, height: 20)
                }
                .labelStyle(.titleAndIcon)

                Button {
                    logsActivityItem = ActivityItem(itemsArray: logURLs ?? [])
                } label: {
                    Label {
                        Text("Share")
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 20, height: 20)
                    }
                    .labelStyle(.titleAndIcon)
                }
                .disabled(logURLs == nil)
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

