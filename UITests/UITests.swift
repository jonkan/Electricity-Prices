//
//  Electricity_Prices_UI_Tests.swift
//  Electricity Prices UI Tests
//
//  Created by Jonas Bromö on 2024-04-20.
//

import XCTest

final class ElectricityPricesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        Task { @MainActor in
            let app = XCUIApplication()
            app.launchArguments += ["-ShowCheapestHours", "NO"]
            setupSnapshot(app)
            app.launch()
        }
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        snapshot("1MainView")

#if os(iOS)
        app.buttons["settings"].tap()
        app.buttons["viewMode"].tap()
        app.buttons["todayAndTomorrow"].tap()
        app.buttons["done"].tap()
        snapshot("3TodayAndTomorrow")

        app.buttons["settings"].tap()
        app.buttons["chart"].tap()
        app.buttons["line"].tap()
        app.buttons["unit"].tap()
        app.buttons["subdivided"].tap()
        app.buttons["done"].tap()
        snapshot("4LineChart")

        app.buttons["settings"].tap()
        app.buttons["chart"].tap()
        app.buttons["bar"].tap()
        app.buttons["unit"].tap()
        app.buttons["automatic"].tap()
        app.buttons["done"].tap()
        XCUIDevice.shared.press(.home)
        sleep(2)
        snapshot("2HomeScreen")

        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        XCUIDevice.shared.press(.home)
        sleep(2)
        snapshot("5LockScreen")

#elseif os(watchOS)
        app.swipeLeft()
        app.swipeLeft()
        app.buttons["viewMode"].tap()
        app.buttons["todayAndTomorrow"].tap()
        app.swipeRight()
        snapshot("2TodayAndTomorrow")

        app.swipeLeft()
        app.buttons["chart"].tap()
        app.buttons["line"].tap()
        app.buttons["unit"].tap()
        app.buttons["subdivided"].tap()
        app.swipeRight()
        snapshot("4LineChart")

        app.swipeLeft()
        app.buttons["chart"].tap()
        app.buttons["bar"].tap()
        app.swipeRight()

        XCUIDevice.shared.press(.home)
        sleep(1)
        snapshot("3HomeScreen")
#endif

    }

}
