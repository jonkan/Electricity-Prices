//
//  PriceAreaSettingsView.swift
//  EPWatchWatchKitApp
//
//  Created by Jonas Bromö on 2022-09-14.
//

import SwiftUI
import EPWatchCore

//struct PriceAreaSettingsView: View {
//
//    @Environment(\.dismiss) var dismiss
//    var priceAreas: [PriceArea]
//    @Binding var priceArea: PriceArea
//
//    var body: some View {
//        ScrollView {
//            ForEach(priceAreas) { pa in
//                Button {
//                    priceArea = pa
//                    dismiss()
//                } label: {
//                    HStack {
//                        Text(pa.title)
//                        Spacer()
//                        if pa == priceArea {
//                            Image(systemName: "checkmark")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
//
//struct PriceAreaSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PriceAreaSettingsView(
//            priceAreas: Region.sweden.priceAreas,
//            priceArea: .constant(Region.sweden.priceAreas[2])
//        )
//    }
//}
//
