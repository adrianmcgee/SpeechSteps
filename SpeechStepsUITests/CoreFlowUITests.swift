import XCTest

/// End-to-end coverage of the journeys that matter: first-run setup, adding a word, and
/// running a full practice session to its celebration. Launches with `-localStore` so the
/// app uses a throwaway in-memory store and every run starts from a clean slate.
final class CoreFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-localStore"]
        app.launch()
    }

    /// Disclaimer → onboarding → land in the app, then run a practice to the summary.
    func testFirstRunThroughToPracticeSummary() {
        DisclaimerScreen(app: app).accept()
        OnboardingScreen(app: app).createChild(named: "Mia")

        attachScreenshot(name: "Today")

        let today = TodayScreen(app: app)
        today.startPractice()

        // Onboarding seeds three active CV words; log each and advance.
        let practice = PracticeScreen(app: app)
        for _ in 0..<3 {
            XCTAssertTrue(app.buttons["practice.rating.correct"].waitForExistence(timeout: 5))
            practice.logCorrect()
            if app.buttons["practice.next"].exists {
                practice.next()
            }
        }
        if app.buttons["practice.done"].exists { practice.finish() }

        XCTAssertTrue(practice.waitForSummary(), "session should end on the celebration screen")
        attachScreenshot(name: "Summary")
    }

    /// Add a brand-new word from the Targets tab.
    func testAddTargetWord() {
        DisclaimerScreen(app: app).accept()
        OnboardingScreen(app: app).createChild(named: "Sam")

        TabBar(app: app).targets()
        TargetsScreen(app: app).add(word: "zoo")

        XCTAssertTrue(app.staticTexts["zoo"].waitForExistence(timeout: 5),
                      "the new word should appear in the target bank")
    }

    /// The reference library and learn sections should open without a child-data dependency.
    func testNavigateLearn() {
        DisclaimerScreen(app: app).accept()
        OnboardingScreen(app: app).createChild(named: "Sam")

        TabBar(app: app).learn()
        XCTAssertTrue(app.staticTexts["What is apraxia of speech?"].waitForExistence(timeout: 5))
    }

    private func attachScreenshot(name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
