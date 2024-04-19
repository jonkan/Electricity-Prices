//
//  LogFileURL.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2024-04-24.
//

import SwiftUI

struct LogFileURL: Transferable {
    let fileURL: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .text) { document in
            SentTransferredFile(document.fileURL)
        }
        .suggestedFileName { document in
            document.fileURL.lastPathComponent
        }
    }
}
