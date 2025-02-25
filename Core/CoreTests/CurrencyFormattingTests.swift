//
//  CurrencyFormattingTests.swift
//  CoreTests
//
//  Created by Jonas Bromö on 2022-10-25.
//

import Foundation
import Testing
@testable import Core

struct CurrencyFormattingTests {

    // MARK: Normal (length), Automatic (unit/symbol)

    @Test
    func testNormalAutomaticLarge() {
        #expect(Currency.SEK.formatted(10.12, .normal, .automatic) == "10,1 kr")
    }

    @Test
    func testNormalAutomaticMedium() {
        #expect(Currency.SEK.formatted(5.12, .normal, .automatic) == "5,12 kr")
    }

    @Test
    func testNormalAutomaticSmall() {
        #expect(Currency.SEK.formatted(0.128, .normal, .automatic) == "13 öre")
    }

    @Test
    func testNormalAutomaticVerySmall() {
        #expect(Currency.SEK.formatted(0.00128, .normal, .automatic) == "0,13 öre")
    }

    // MARK: Short (length), Automatic (unit/symbol)

    @Test
    func testShortAutomaticLarge() {
        #expect(Currency.SEK.formatted(10.12, .short, .automatic) == "10")
    }

    @Test
    func testShortAutomaticMedium() {
        #expect(Currency.SEK.formatted(5.12, .short, .automatic) == "5,1")
    }

    @Test
    func testShortAutomaticSmall() {
        #expect(Currency.SEK.formatted(0.128, .short, .automatic) == "0,1")
    }

    @Test
    func testShortAutomaticVerySmall() {
        #expect(Currency.SEK.formatted(0.00128, .short, .automatic) == "0,0")
    }

    // MARK: Normal (length), Subdivided (unit/symbol)

    @Test
    func testNormalSubdividedLarge() {
        #expect(Currency.SEK.formatted(10.12, .normal, .subdivided) == "1 012 öre")
    }

    @Test
    func testNormalSubdividedMedium() {
        #expect(Currency.SEK.formatted(5.12, .normal, .subdivided) == "512 öre")
    }

    @Test
    func testNormalSubdividedSmall() {
        #expect(Currency.SEK.formatted(0.128, .normal, .subdivided) == "12,8 öre")
    }

    @Test
    func testNormalSubdividedVerySmall() {
        #expect(Currency.SEK.formatted(0.00128, .normal, .subdivided) == "0,128 öre")
    }

    // MARK: Short (length), Subdivided (unit/symbol)

    @Test
    func testShortSubdividedLarge() {
        #expect(Currency.SEK.formatted(10.12, .short, .subdivided) == "1012")
    }

    @Test
    func testShortSubdividedMedium() {
        #expect(Currency.SEK.formatted(5.12, .short, .subdivided) == "512")
    }

    @Test
    func testShortSubdividedSmall() {
        #expect(Currency.SEK.formatted(0.128, .short, .subdivided) == "13")
    }

    @Test
    func testShortSubdividedVerySmall() {
        #expect(Currency.SEK.formatted(0.00128, .short, .subdivided) == "0,1")
    }

}
