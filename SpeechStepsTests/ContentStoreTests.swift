import XCTest
@testable import SpeechSteps

/// The bundled reference content is shipped knowledge the app leans on, so a malformed
/// edit should fail loudly in CI rather than silently empty a library.
final class ContentStoreTests: XCTestCase {

    func testBundledContentDecodes() {
        let store = ContentStore()
        XCTAssertFalse(store.phonemes.isEmpty, "phonemes.json should decode")
        XCTAssertFalse(store.signs.isEmpty, "signs.json should decode")
        XCTAssertFalse(store.starterTargets.isEmpty, "starter_targets.json should decode")
    }

    func testEveryStarterTargetSoundExists() {
        let store = ContentStore()
        let ids = Set(store.phonemes.map(\.id))
        for target in store.starterTargets {
            for phonemeID in target.phonemeIDs {
                XCTAssertTrue(ids.contains(phonemeID),
                              "starter target \(target.text) references unknown sound \(phonemeID)")
            }
        }
    }

    func testStarterTargetsCoverEarlyShapes() {
        let shapes = Set(ContentStore().starterTargets.map(\.shape))
        XCTAssertTrue(shapes.contains(.cv))
        XCTAssertTrue(shapes.contains(.vc))
        XCTAssertTrue(shapes.contains(.cvc))
    }

    func testSignsGroupPreservesCategoryOrder() {
        let groups = ContentStore().signsByCategory
        XCTAssertFalse(groups.isEmpty)
        XCTAssertEqual(groups.map(\.category).count, Set(groups.map(\.category)).count,
                       "each category should appear once")
    }
}
