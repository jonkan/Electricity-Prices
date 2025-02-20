//
//  Badge.swift
//  Electricity Prices
//
//  Created by Jonas Värbrand on 2025-02-20.
//

import SwiftUI

enum BadgeStyle {
    case hidden
    case dot
}

extension View {
    func badge(_ style: BadgeStyle) -> some View {
        modifier(BadgeViewModifier(style: style))
    }
}

private struct BadgeViewModifier: ViewModifier {
    let style: BadgeStyle

    func body(content: Content) -> some View {
        let size = UIFontMetrics.default.scaledValue(for: 12)
        ZStack(alignment: .topTrailing) {
            content
            if style != .hidden {
                Capsule()
                    .foregroundStyle(.red)
                    .frame(width: size, height: size)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .navigationTitle("Title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "gearshape")
                            .bold()
                            .foregroundColor(.primary)
                            .badge(.dot)
                    }
                }
            }
    }
}
