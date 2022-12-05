//
//  CurrencyFormattingTests.swift
//  EPWatchCoreTests
//
//  Created by Jonas Bromö on 2022-10-25.
//

import XCTest
@testable import EPWatchCore

final class CurrencyFormattingTests: XCTestCase {

    // MARK: Normal (length), Automatic (unit/symbol)

    func testNormalAutomaticLarge() {
        XCTAssertEqual(Currency.SEK.formatted(10.12, .normal, .automatic), "10,1 kr")
    }

    func testNormalAutomaticMedium() {
        XCTAssertEqual(Currency.SEK.formatted(5.12, .normal, .automatic), "5,12 kr")
    }

    func testNormalAutomaticSmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.128, .normal, .automatic), "13 öre")
    }

    func testNormalAutomaticVerySmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.00128, .normal, .automatic), "0,13 öre")
    }

    // MARK: Short (length), Automatic (unit/symbol)

    func testShortAutomaticLarge() {
        XCTAssertEqual(Currency.SEK.formatted(10.12, .short, .automatic), "10")
    }

    func testShortAutomaticMedium() {
        XCTAssertEqual(Currency.SEK.formatted(5.12, .short, .automatic), "5,1")
    }

    func testShortAutomaticSmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.128, .short, .automatic), "0,1")
    }

    func testShortAutomaticVerySmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.00128, .short, .automatic), "0,0")
    }

    // MARK: Normal (length), Subdivided (unit/symbol)

    func testNormalSubdividedLarge() {
        XCTAssertEqual(Currency.SEK.formatted(10.12, .normal, .subdivided), "1 012 öre")
    }

    func testNormalSubdividedMedium() {
        XCTAssertEqual(Currency.SEK.formatted(5.12, .normal, .subdivided), "512 öre")
    }

    func testNormalSubdividedSmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.128, .normal, .subdivided), "12,8 öre")
    }

    func testNormalSubdividedVerySmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.00128, .normal, .subdivided), "0,128 öre")
    }

    // MARK: Short (length), Subdivided (unit/symbol)

    func testShortSubdividedLarge() {
        XCTAssertEqual(Currency.SEK.formatted(10.12, .short, .subdivided), "1012")
    }

    func testShortSubdividedMedium() {
        XCTAssertEqual(Currency.SEK.formatted(5.12, .short, .subdivided), "512")
    }

    func testShortSubdividedSmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.128, .short, .subdivided), "13")
    }

    func testShortSubdividedVerySmall() {
        XCTAssertEqual(Currency.SEK.formatted(0.00128, .short, .subdivided), "0,1")
    }

}
