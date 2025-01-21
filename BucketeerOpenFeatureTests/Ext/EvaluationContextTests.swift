import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("EvaluationContext Extenstion Tests")
struct EvaluationContextExtTests {
    @Test func toBKTUserSuccess() async throws {
        let testcases = [
            (MutableContext(
                targetingKey: "targetingKey",
                structure: MutableStructure(
                    attributes: [
                        "key": .string("value")
                    ]
                )), try BKTUser.Builder().with(id: "targetingKey").with(attributes: ["key": "value"]).build()),
            (MutableContext(
                targetingKey: "targetingKey",
                structure: MutableStructure(
                    attributes: [:]
                )), try BKTUser.Builder().with(id: "targetingKey").with(attributes: [:]).build())
        ]

        for (context, expectedUser) in testcases {
            let actualUser = try context.toBKTUser()
            #expect(actualUser.id == expectedUser.id)
            #expect(actualUser.attr == expectedUser.attr)
        }
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
