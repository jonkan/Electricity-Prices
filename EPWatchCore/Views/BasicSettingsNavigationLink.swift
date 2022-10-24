//
//  BasicSettingsNavigationLink.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-23.
//

import SwiftUI

public struct BasicSettingsNavigationLink<SettingsValue: Identifiable & Equatable>: View {

    var title: String
    var values: [SettingsValue]
    @Binding var currentValue: SettingsValue?
    var displayValue: (SettingsValue) -> String

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
            .navigationTitle(title.localized)
        } label: {
            HStack {
                Text(title.localized)
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
