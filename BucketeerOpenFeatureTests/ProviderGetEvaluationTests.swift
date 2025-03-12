import Testing
 import Foundation
 import Bucketeer
 import OpenFeature
 @testable import BucketeerOpenFeature

 @Suite("Provider Get Evaluations Tests")
 struct ProviderGetEvaluationsTests {

    let mockBucketeerClient: MockBucketeerClient
    let mockBucketeerDI: MockBucketeerDI
    let config: BKTConfig
    let provider: BucketeerProvider

    init() throws {
        let logger = MockLogger()
        // Not set interval values
        let builder = BKTConfig.Builder()
            .with(apiKey: "api_key_value")
            .with(apiEndpoint: "https://test.bucketeer.io")
            .with(featureTag: "featureTag1")
            .with(appVersion: "1.2.3")
            .with(logger: logger)

        config = try builder.build()
        mockBucketeerClient = MockBucketeerClient()
        mockBucketeerDI = MockBucketeerDI(client: mockBucketeerClient)
        provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
    }

     func requiredInitSuccess() async throws {
         let context = MutableContext(
             targetingKey: "targetingKey",
             structure: MutableStructure(
                 attributes: [:]
             )
         )
         try await provider.initialize(initialContext: context)
     }

    @Test("getMetadata should returns correct metadata")
    func getMetadataReturnsCorrectMetadata() {
        // Arrange
        let provider = self.provider

        // Act & Assert
        #expect(provider.metadata.name == "Bucketeer Feature Flag Provider")
    }

    @Test func getBooleanEvaluation() async throws {
        try await requiredInitSuccess()
        let bktEvaluationDetails = BKTEvaluationDetails<Bool>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: true,
            reason: .prerequisite)
        let expected = ProviderEvaluation<Bool>(
            value: true,
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")
        mockBucketeerClient.mockBoolValue = bktEvaluationDetails

        let actual = try provider.getBooleanEvaluation(key: "key", defaultValue: false, context: nil)
        #expect(actual.value == expected.value)
        #expect(actual.flagMetadata == expected.flagMetadata)
        #expect(actual.variant == expected.variant)
        #expect(actual.reason == expected.reason)
    }

    @Test func getStringEvaluation() async throws {
        try await requiredInitSuccess()
        let bktEvaluationDetails = BKTEvaluationDetails<String>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: "value",
            reason: .prerequisite)
        let expected = ProviderEvaluation<String>(
            value: "value",
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")
        mockBucketeerClient.mockStringValue = bktEvaluationDetails

        let actual = try provider.getStringEvaluation(key: "key", defaultValue: "", context: nil)
        #expect(actual.value == expected.value)
        #expect(actual.flagMetadata == expected.flagMetadata)
        #expect(actual.variant == expected.variant)
        #expect(actual.reason == expected.reason)
    }

    @Test func getIntegerEvaluation() async throws {
        try await requiredInitSuccess()
        let bktEvaluationDetails = BKTEvaluationDetails<Int>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: 1,
            reason: .prerequisite)
        let expected = ProviderEvaluation<Int64>(
            value: 1,
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")
        mockBucketeerClient.mockIntValue = bktEvaluationDetails

        let actual = try provider.getIntegerEvaluation(key: "key", defaultValue: 0, context: nil)
        #expect(actual.value == expected.value)
        #expect(actual.flagMetadata == expected.flagMetadata)
        #expect(actual.variant == expected.variant)
        #expect(actual.reason == expected.reason)
    }

    @Test func getDoubleEvaluation() async throws {
        try await requiredInitSuccess()
        let bktEvaluationDetails = BKTEvaluationDetails<Double>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: 1.0,
            reason: .prerequisite)
        let expected = ProviderEvaluation<Double>(
            value: 1.0,
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")
        mockBucketeerClient.mockDoubleValue = bktEvaluationDetails

        let actual = try provider.getDoubleEvaluation(key: "key", defaultValue: 0.0, context: nil)
        #expect(actual.value == expected.value)
        #expect(actual.flagMetadata == expected.flagMetadata)
        #expect(actual.variant == expected.variant)
        #expect(actual.reason == expected.reason)
    }

    @Test func getObjectEvaluation() async throws {
        try await requiredInitSuccess()
        let bktEvaluationDetails = BKTEvaluationDetails<BKTValue>(
            featureId: "featureId2",
            featureVersion: 2,
            userId: "userId2",
            variationId: "1",
            variationName: "2",
            variationValue: .dictionary(["key": .string("value-1")]),
            reason: .prerequisite)
        let expected = ProviderEvaluation<Value>(
            value: .structure(["key": .string("value-1")]),
            flagMetadata: [:],
            variant: nil,
            reason: "PREREQUISITE")

        mockBucketeerClient.mockObjectValue = bktEvaluationDetails

        let actual = try provider.getObjectEvaluation(key: "key", defaultValue: .null, context: nil)
        #expect(actual.value == expected.value)
        #expect(actual.flagMetadata == expected.flagMetadata)
        #expect(actual.variant == expected.variant)
        #expect(actual.reason == expected.reason)
    }
 }
