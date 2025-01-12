import XCTest
import Foundation
import Bucketeer
import OpenFeature
import Combine
@testable import BucketeerOpenFeature

final class E2EProviderGetEvaluationTests: XCTestCase {
    var provider: BucketeerProvider!
    var initContext: EvaluationContext!

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "bucketeer_user_evaluations_id")

        let config = try BKTConfig.e2e()
        provider = BucketeerProvider(config: config)

        let context = MutableContext(
            targetingKey: Constant.userId,
            structure: MutableStructure(
                attributes: [:]
            )
        )

        self.initContext = context
    }

    override func tearDownWithError() throws {
        OpenFeatureAPI.shared.clearProvider()
    }

    func requiredInitSuccess() async throws {
        // Set context before initialize
        await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: initContext)
        // Assert
        XCTAssertEqual(OpenFeatureAPI.shared.getProviderStatus(), .ready)
    }

    func testInitializeSuccessWithCorrectUserData() async throws {
        try await requiredInitSuccess()

        // Check user attributes
        XCTAssertEqual(provider.client?.currentUser()?.attr, [:])
        XCTAssertEqual(provider.client?.currentUser()?.id, Constant.userId)
    }

    func testShouldUpdateTheUserAttributeWhenContextChange() async throws {
        try await requiredInitSuccess()
        let newContext = MutableContext(
            targetingKey: Constant.userId,
            structure: MutableStructure(
                attributes: ["tag": .string("ios"), "age": .integer(20)]
            )
        )
        OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: newContext)

        // Wait for the Bucketeer client to update the user attributes
        // Because setEvaluationContext is sync, but the update is async
        try await Task.sleep(nanoseconds: 1_000_000)

        // Check user attributes
        XCTAssertEqual(provider.client?.currentUser()?.attr["age"], "20")
        XCTAssertEqual(provider.client?.currentUser()?.attr["tag"], "ios")
        XCTAssertEqual(provider.client?.currentUser()?.id, Constant.userId)
    }

    func testShouldNotUpdateTheUserAttribute() async throws {
        try await requiredInitSuccess()
        let newContext = MutableContext(
            targetingKey: "new_target_key",
            structure: MutableStructure(
                attributes: [:]))
        // Wait for the Bucketeer client to update the user attributes
        // Because setEvaluationContext is sync, but the update is async
        OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: newContext)
        try await Task.sleep(nanoseconds: 3_000_000)
        XCTAssertEqual(OpenFeatureAPI.shared.getProviderStatus(), .error)
    }

    func testGetBooleanEvaluation() async throws {
        try await requiredInitSuccess()
        let featureId = Constant.featureIdBoolean
        let defaultValue = false
        let client = OpenFeatureAPI.shared.getClient()
        let evaluation = client.getBooleanValue(key: featureId, defaultValue: defaultValue)
        XCTAssertEqual(evaluation, true)

        let evaluationDetails = client.getBooleanDetails(key: featureId, defaultValue: defaultValue)
        let expectedEvaluationDetails = ProviderEvaluation<Bool>(
            value: true,
            flagMetadata: [:],
            variant: nil,
            reason: "DEFAULT"
        )

        XCTAssertEqual(evaluationDetails.value, expectedEvaluationDetails.value)
        XCTAssertEqual(evaluationDetails.flagMetadata, expectedEvaluationDetails.flagMetadata)
        XCTAssertEqual(evaluationDetails.variant, expectedEvaluationDetails.variant)
        XCTAssertEqual(evaluationDetails.reason, expectedEvaluationDetails.reason)
    }

    func testGetIntegerEvaluation() async throws {
        try await requiredInitSuccess()
        let featureId = Constant.featureIdInteger
        let defaultValue: Int64 = 101
        let client = OpenFeatureAPI.shared.getClient()
        let evaluation = client.getIntegerValue(key: featureId, defaultValue: defaultValue)
        XCTAssertEqual(evaluation, 10)

        let evaluationDetails = client.getIntegerDetails(key: featureId, defaultValue: defaultValue)
        let expectedEvaluationDetails = ProviderEvaluation<Int64>(
            value: 10,
            flagMetadata: [:],
            variant: nil,
            reason: "DEFAULT"
        )

        XCTAssertEqual(evaluationDetails.value, expectedEvaluationDetails.value)
        XCTAssertEqual(evaluationDetails.flagMetadata, expectedEvaluationDetails.flagMetadata)
        XCTAssertEqual(evaluationDetails.variant, expectedEvaluationDetails.variant)
        XCTAssertEqual(evaluationDetails.reason, expectedEvaluationDetails.reason)
    }

    func testGetDoubleEvaluation() async throws {
        try await requiredInitSuccess()
        let featureId = Constant.featureIdDouble
        let defaultValue: Double = 101.0
        let client = OpenFeatureAPI.shared.getClient()
        let evaluation = client.getDoubleValue(key: featureId, defaultValue: defaultValue)
        XCTAssertEqual(evaluation, 2.1)

        let evaluationDetails = client.getDoubleDetails(key: featureId, defaultValue: defaultValue)
        let expectedEvaluationDetails = ProviderEvaluation<Double>(
            value: 2.1,
            flagMetadata: [:],
            variant: nil,
            reason: "DEFAULT"
        )

        XCTAssertEqual(evaluationDetails.value, expectedEvaluationDetails.value)
        XCTAssertEqual(evaluationDetails.flagMetadata, expectedEvaluationDetails.flagMetadata)
        XCTAssertEqual(evaluationDetails.variant, expectedEvaluationDetails.variant)
        XCTAssertEqual(evaluationDetails.reason, expectedEvaluationDetails.reason)
    }

    func testGetStringEvaluation() async throws {
        try await requiredInitSuccess()
        let featureId = Constant.featureIdString
        let defaultValue: String = "default"
        let client = OpenFeatureAPI.shared.getClient()
        let evaluation = client.getStringValue(key: featureId, defaultValue: defaultValue)
        XCTAssertEqual(evaluation, "value-1")

        let evaluationDetails = client.getStringDetails(key: featureId, defaultValue: defaultValue)
        let expectedEvaluationDetails = ProviderEvaluation<String>(
            value: "value-1",
            flagMetadata: [:],
            variant: nil,
            reason: "DEFAULT"
        )

        XCTAssertEqual(evaluationDetails.value, expectedEvaluationDetails.value)
        XCTAssertEqual(evaluationDetails.flagMetadata, expectedEvaluationDetails.flagMetadata)
        XCTAssertEqual(evaluationDetails.variant, expectedEvaluationDetails.variant)
        XCTAssertEqual(evaluationDetails.reason, expectedEvaluationDetails.reason)
    }

    func testGetObjectEvaluation() async throws {
        try await requiredInitSuccess()
        let featureId = Constant.featureIdJson
        let defaultValue: Value = .structure([:])
        let client = OpenFeatureAPI.shared.getClient()
        let evaluation = client.getObjectValue(key: featureId, defaultValue: defaultValue)
        XCTAssertEqual(evaluation, .structure(["key": .string("value-1")]))

        let evaluationDetails = client.getObjectDetails(key: featureId, defaultValue: defaultValue)
        let expectedEvaluationDetails = ProviderEvaluation<Value>(
            value: .structure(["key": .string("value-1")]),
            flagMetadata: [:],
            variant: nil,
            reason: "DEFAULT"
        )

        XCTAssertEqual(evaluationDetails.value, expectedEvaluationDetails.value)
        XCTAssertEqual(evaluationDetails.flagMetadata, expectedEvaluationDetails.flagMetadata)
        XCTAssertEqual(evaluationDetails.variant, expectedEvaluationDetails.variant)
        XCTAssertEqual(evaluationDetails.reason, expectedEvaluationDetails.reason)
    }
}
