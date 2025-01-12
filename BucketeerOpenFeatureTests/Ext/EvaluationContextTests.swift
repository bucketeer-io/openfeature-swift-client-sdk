import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("EvaluationContext Extenstion Tests")
struct EvaluationContextExtTests {
    @Test("Convert MutableContext to BKTUser", arguments: [
        (
            MutableContext(
                targetingKey: "targetingKey",
                structure: MutableStructure(
                    attributes: ["key": .string("value")]
                )
            ),
            try BKTUser.Builder().with(id: "targetingKey").with(attributes: ["key": "value"]).build()
        ),
        (
            MutableContext(
                targetingKey: "targetingKey",
                structure: MutableStructure(
                    attributes: [:]
                )
            ),
            try BKTUser.Builder().with(id: "targetingKey").with(attributes: [:]).build()
        )
    ])
    func toBKTUserSuccess(testCase: (context: MutableContext, expectedUser: BKTUser)) async throws {
        let actualUser = try testCase.context.toBKTUser()

        #expect(actualUser.id == testCase.expectedUser.id)
        #expect(actualUser.attr == testCase.expectedUser.attr)
    }

    @Test func toBKTUserFailBecauseMissingTargetKey() async throws {
        let context = MutableContext(
            attributes: [
                "key": .string("value")
            ])

        do {
            _ = try context.toBKTUser()
        } catch {
            // error should be OpenFeatureError.targetingKeyMissingError
            #expect(error is OpenFeatureError)
            #expect(error as? OpenFeatureError == OpenFeatureError.targetingKeyMissingError)
        }
    }
}
