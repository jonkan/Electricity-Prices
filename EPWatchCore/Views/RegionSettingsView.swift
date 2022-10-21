//
//  RegionSettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import SwiftUI

public struct RegionSettingsView: View {

    var regions: [Region]
    @Binding var region: Region?
    @Environment(\.dismiss) private var dismiss

    public init(regions: [Region], region: Binding<Region?>) {
        self.regions = regions
        self._region = region
    }

    public var body: some View {
        List {
            ForEach(regions) { r in
                Button {
                    region = r
                    dismiss()
                } label: {
                    HStack {
                        Text(r.name)
                        Spacer()
                        if r == region {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

}
