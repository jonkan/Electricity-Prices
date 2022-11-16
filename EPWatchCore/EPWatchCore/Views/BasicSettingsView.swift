//
//  BasicSettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-23.
//

import SwiftUI

public struct BasicSettingsView<SettingsValue: Identifiable & Equatable>: View {

    let values: [SettingsValue]
    @Binding var currentValue: SettingsValue?
    let displayValue: (SettingsValue) -> String
    @Environment(\.dismiss) private var dismiss

    public init(
        values: [SettingsValue],
        currentValue: Binding<SettingsValue?>,
        displayValue: @escaping (SettingsValue) -> String
    ) {
        self.values = values
        self._currentValue = currentValue
        self.displayValue = displayValue
    }

    public var body: some View {
        List {
            ForEach(values) { value in
                Button {
                    currentValue = value
                    dismiss()
                } label: {
                    HStack {
                        Text(displayValue(value))
                        Spacer()
                        if value == currentValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

}

struct BasicSettingsView_Previews: PreviewProvider {
    enum Setting: String, CaseIterable, Identifiable {
        case a, b, c
        var id: String { rawValue }
    }
    static var previews: some View {
        BasicSettingsView(
            values: Setting.allCases,
            currentValue: .constant(.a),
            displayValue: { $0.rawValue }
        )
    }
}
