//
//  Utils.swift
//  Core
//
//  Created by Jonas Värbrand on 2025-02-25.
//

import Foundation

func almostEqual(_ a: Double, _ b: Double, accuracy: Double = 1e-10) -> Bool {
    abs(a - b) < accuracy
}
