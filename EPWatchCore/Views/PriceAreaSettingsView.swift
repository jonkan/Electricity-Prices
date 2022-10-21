//
//  PriceAreaSettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI

public struct PriceAreaSettingsView: View {

    var priceAreas: [PriceArea]
    @Binding var priceArea: PriceArea?
    @Environment(\.dismiss) private var dismiss

    public init(priceAreas: [PriceArea], priceArea: Binding<PriceArea?>) {
        self.priceAreas = priceAreas
        self._priceArea = priceArea
    }

    public var body: some View {
        List {
            ForEach(priceAreas) { pa in
                Button {
                    priceArea = pa
                    dismiss()
                } label: {
                    HStack {
                        Text(pa.title)
                        Spacer()
                        if pa == priceArea {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

}
