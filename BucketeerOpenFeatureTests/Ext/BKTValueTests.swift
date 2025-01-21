import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("BKTValue Extenstion Tests")
struct BKTValueExtTests {
    @Test("Convert BKTValue to OpenFeature Value", arguments: [(BKTValue, Value)]([
        (.boolean(true), .boolean(true)),
        (.string("string"), .string("string")),
        (.number(1.0), .double(1.0)),
        (.list([.boolean(true), .string("string")]), .list([.boolean(true), .string("string")])),
        (.dictionary(["key": .boolean(true), "key2": .string("string")]),
         .structure(["key": .boolean(true), "key2": .string("string")])),
        (.null, .null)
    ]))
    func toOpenFeatureValue(testCase: (input: BKTValue, expected: Value)) async throws {
        let actualValue = testCase.input.toOpenFeatureValue()
        #expect(actualValue == testCase.expected)
    }
}
