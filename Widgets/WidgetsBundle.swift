//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Jonas Bromö on 2024-04-19.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    @MainActor
    var body: some Widget {
        ElectricityPricesWidget()
    }
}
