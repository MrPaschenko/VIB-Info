import XCTest

final class VIB_UITests: XCTestCase {
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        snapshot("Departures")
        
//        let tabBar = app.tabBars.firstMatch
//        let arrivalsTabBarItem = tabBar.buttons["arrivals"]
//        arrivalsTabBarItem.tap()
        
//        snapshot("Arrivals")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
