//
//  View+WidgetBackground.swift
//
//
//  Created by Jonas Bromö on 2023-09-21.
//

import SwiftUI

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOS 17.0, *), #available(iOSApplicationExtension 17.0, *), #available(watchOS 10.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
