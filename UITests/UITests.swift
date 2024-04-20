//
//  Electricity_Prices_UI_Tests.swift
//  Electricity Prices UI Tests
//
//  Created by Jonas Bromö on 2024-04-20.
//

import XCTest

final class ElectricityPricesUITests: XCTestCase {

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        snapshot("0MainView")
        XCUIDevice.shared.press(.home)
        sleep(1)
        snapshot("1Homescreen")
        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        sleep(1)
        snapshot("2LockScreen")
    }

}
