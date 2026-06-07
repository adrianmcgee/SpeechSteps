import XCTest
import SwiftData
@testable import TadpoleTalk

@MainActor
final class PersistenceTests: XCTestCase {

    func testTargetRoundTripAndShapeMapping() throws {
        let context = try TestSupport.makeContext()
        let child = TestSupport.makeChild(in: context)
        let target = WordTarget(text: "cup", shape: .cvc, phonemeIDs: ["k", "p"], isActiveThisWeek: true)
        target.child = child
        context.insert(target)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WordTarget>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.shape, .cvc)
        XCTAssertEqual(fetched.first?.phonemeIDs, ["k", "p"])
        XCTAssertTrue(fetched.first?.isActiveThisWeek ?? false)
    }

    func testDeletingChildCascadesTargetsAndSessions() throws {
        let context = try TestSupport.makeContext()
        let child = TestSupport.makeChild(in: context)
        let target = WordTarget(text: "go", shape: .cv); target.child = child; context.insert(target)
        TestSupport.addSession(to: child, in: context, on: Date(), ratings: [.correct, .approx])
        try context.save()

        context.delete(child)
        try context.save()

        XCTAssertEqual(try context.fetch(FetchDescriptor<WordTarget>()).count, 0)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PracticeSession>()).count, 0)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Trial>()).count, 0)
    }

    func testSessionSummaryCountsSuccesses() throws {
        let context = try TestSupport.makeContext()
        let child = TestSupport.makeChild(in: context)
        TestSupport.addSession(to: child, in: context, on: Date(),
                               ratings: [.correct, .correct, .approx, .tryAgain])
        let session = try context.fetch(FetchDescriptor<PracticeSession>()).first
        XCTAssertEqual(session?.totalCount, 4)
        XCTAssertEqual(session?.successCount, 2)
        XCTAssertEqual(session?.successRate ?? 0, 0.5, accuracy: 0.001)
    }

    func testActiveTargetsAreSortedByShape() throws {
        let context = try TestSupport.makeContext()
        let child = TestSupport.makeChild(in: context)
        for (text, shape) in [("cup", SyllableShape.cvc), ("go", .cv), ("up", .vc)] {
            let t = WordTarget(text: text, shape: shape, isActiveThisWeek: true)
            t.child = child; context.insert(t)
        }
        try context.save()
        XCTAssertEqual(child.activeTargets.map(\.shape), [.cv, .vc, .cvc])
    }
}
