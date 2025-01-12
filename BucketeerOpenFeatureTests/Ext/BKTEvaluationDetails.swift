import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("BKTEvaluationDetails Extenstion Tests")
struct ToProviderEvaluationExtTests {
    @Test func bktValue() async throws {
        let bktEvaluationDetails = BKTEvaluationDetails<BKTValue>(
            featureId: "featureId",
            featureVersion: 0,
            userId: "userId",
            variationId: "",
            variationName: "",
            variationValue: .boolean(true),
            reason: .client)
        let expectedProviderEvaluation = ProviderEvaluation<Value>(
            value: .boolean(true),
            flagMetadata: [:],
            variant: nil,
            reason: "CLIENT")
        let actualProviderEvaluation = bktEvaluationDetails.toProviderEvaluation(overrideValue: nil)

        #expect(actualProviderEvaluation.value == expectedProviderEvaluation.value)
        #expect(actualProviderEvaluation.flagMetadata == expectedProviderEvaluation.flagMetadata)
        #expect(actualProviderEvaluation.variant == expectedProviderEvaluation.variant)
        #expect(actualProviderEvaluation.reason == expectedProviderEvaluation.reason)
    }

    @Test func bktValueCase2() async throws {
        let bktEvaluationDetails = BKTEvaluationDetails<BKTValue>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: .string("okay"),
            reason: .prerequisite)
        let expectedProviderEvaluation = ProviderEvaluation<Value>(
            value: .string("okay"),
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")
        let actualProviderEvaluation = bktEvaluationDetails.toProviderEvaluation(overrideValue: nil)

        #expect(actualProviderEvaluation.value == expectedProviderEvaluation.value)
        #expect(actualProviderEvaluation.flagMetadata == expectedProviderEvaluation.flagMetadata)
        #expect(actualProviderEvaluation.variant == expectedProviderEvaluation.variant)
        #expect(actualProviderEvaluation.reason == expectedProviderEvaluation.reason)
    }

    @Test func string() async throws {
        let bktEvaluationDetails = BKTEvaluationDetails<String>(
            featureId: "featureId",
            featureVersion: 0,
            userId: "userId",
            variationId: "",
            variationName: "",
            variationValue: "string",
            reason: .client)
        let expectedProviderEvaluation = ProviderEvaluation<String>(
            value: "string",

            flagMetadata: [:],
            variant: nil,
            reason: "CLIENT")

        let actualProviderEvaluation = bktEvaluationDetails.toProviderEvaluation()

        #expect(actualProviderEvaluation.value == expectedProviderEvaluation.value)
        #expect(actualProviderEvaluation.flagMetadata == expectedProviderEvaluation.flagMetadata)
        #expect(actualProviderEvaluation.variant == expectedProviderEvaluation.variant)
        #expect(actualProviderEvaluation.reason == expectedProviderEvaluation.reason)
    }
}
