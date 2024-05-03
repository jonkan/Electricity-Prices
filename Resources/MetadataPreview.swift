//
//  MetadataPreview.swift
//  Electricity Prices
//
//  Created by Jonas Bromö on 2024-05-03.
//

import SwiftUI

#if DEBUG

// This is used to get these strings into the string catalog,
// which is then used by frameit.
// The strings must match the keys in the Framefile.json
private struct MetadataPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text(String("Screenshot texts"))
                .font(.title)
            screenshotText(
                keyword: "Consume Smarter!",
                title: "Plan ahead and avoid the peaks"
            )
            screenshotText(
                keyword: "Cheaper Tomorrow?",
                title: "Easily compare today's and tomorrow's prices"
            )
            screenshotText(
                keyword: "Customizable",
                title: "To suit your preferences"
            )
            screenshotText(
                keyword: "Widgets",
                title: "Stay updated without opening the app"
            )
            screenshotText(
                keyword: "Lock Screen Widgets",
                title: "See prices at a glance"
            )
        }
    }

    func screenshotText(
        keyword: LocalizedStringKey,
        title: LocalizedStringKey
    ) -> some View {
        VStack {
            Text(keyword)
                .font(.headline)
            Text(title)
                .font(.subheadline)
        }
    }
}

#Preview {
    MetadataPreview()
}

#endif
