//
//  DateIntervalText.swift
//
//
//  Created by Jonas Bromö on 2024-04-26.
//

import SwiftUI

public struct DateIntervalText: View {

    public typealias Duration = (value: Int, component: Calendar.Component)

    let start: Date
    let duration: Duration
    let style: FormattingStyle

    public init(_ start: Date, duration: Duration = (1, .hour), style: FormattingStyle) {
        self.start = start
        self.duration = duration
        self.style = style
    }

    public var body: Text {
        Text(start, format: dateFormatStyle) +
        Text(" - ") +
        Text(end, format: dateFormatStyle)
    }

    private var dateFormatStyle: Date.FormatStyle {
        switch style {
        case .normal:
            return .dateTime.hour().minute()
        case .short:
            return .dateTime.hour(.defaultDigits(amPM: .omitted))
        }
    }

    private var end: Date {
        Calendar.current.date(byAdding: duration.component, value: duration.value, to: start)!
    }

}

#Preview {
    VStack {
        DateIntervalText(.now, style: .normal)
        DateIntervalText(.now, style: .short)
    }
}
