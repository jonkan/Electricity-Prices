//
//  BasicSettingsNavigationLink.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-23.
//

import SwiftUI

public struct BasicSettingsNavigationLink<SettingsValue: Identifiable<String> & Equatable>: View {

    let title: String
    let values: [SettingsValue]
    @Binding var currentValue: SettingsValue?
    let displayValue: (SettingsValue) -> String

    public init(
        title: String,
        values: [SettingsValue],
        currentValue: Binding<SettingsValue?>,
        displayValue: @escaping (SettingsValue) -> String
    ) {
        self.title = title
        self.values = values
        self._currentValue = currentValue
        self.displayValue = displayValue
    }

    public init(
        title: String,
        values: [SettingsValue],
        currentValue: Binding<SettingsValue>,
        displayValue: @escaping (SettingsValue) -> String
    ) {
        self.title = title
        self.values = values
        self._currentValue = Binding(
            get: { currentValue.wrappedValue },
            set: { currentValue.wrappedValue = $0! }
        )
        self.displayValue = displayValue
    }

    public var body: some View {
        NavigationLink {
            BasicSettingsView(
                values: values,
                currentValue: $currentValue,
                displayValue: displayValue
            )
            .navigationTitle(title)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(currentValue != nil ? displayValue(currentValue!) : "")
            }
        }
    }

}

struct BasicSettingsNavigationLink_Previews: PreviewProvider {
    enum Setting: String, CaseIterable, Identifiable {
        case a, b, c
        var id: String { rawValue }
    }
    static var previews: some View {
        BasicSettingsNavigationLink(
            title: "Setting",
            values: Setting.allCases,
            currentValue: .constant(.a),
            displayValue: { $0.rawValue }
        )
    }
}
