//
//  SelectionHaptics.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-11-14.
//

import Foundation
import UIKit

class SelectionHaptics {

    static let shared = SelectionHaptics()

#if os(iOS)
    private var feedbackGenerator: UISelectionFeedbackGenerator? = nil
#endif

    private init() {}

    func changed() {
#if os(iOS)
        if feedbackGenerator == nil {
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
        } else {
            feedbackGenerator?.selectionChanged()
            feedbackGenerator?.prepare()
        }
#endif
    }

    func ended() {
#if os(iOS)
        feedbackGenerator = nil
#endif
    }

}
