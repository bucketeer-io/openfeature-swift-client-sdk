import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("Provider Validate Context Tests")
struct ProviderValidateContextTests {

    let mockBucketeerClient: MockBucketeerClient
    let mockBucketeerDI: MockBucketeerDI
    let config: BKTConfig
    let provider: FeatureProvider
    let initContext: MutableContext

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
        initContext = MutableContext(
            targetingKey: "targetingKey",
            structure: MutableStructure(
                attributes: [:]
            )
        )
        provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
    }

    func requiredInitSuccess() async throws {
        try await provider.initialize(initialContext: initContext)
    }

    @Test func onNewContextIsInvalidMissingTargetingKey() async throws {
        try await requiredInitSuccess()
        await #expect(throws: OpenFeatureError.targetingKeyMissingError, performing: {
            try await provider.onContextSet(oldContext: initContext, newContext: MutableContext(attributes: [:]))
        })
    }

    @Test func onNewContextIsChangeUserIdShouldFail() async throws {
        try await requiredInitSuccess()
        let newContext = MutableContext(
            targetingKey: "newTargetingKey",
            structure: MutableStructure(
                attributes: [:]
            )
        )
        await #expect(throws: OpenFeatureError.invalidContextError, performing: {
            try await provider.onContextSet(oldContext: initContext, newContext: newContext)
        })
    }

    @Test func onNewContextChangeAtributesShouldSuccess() async throws {
        try await requiredInitSuccess()
        #expect(mockBucketeerClient.userAttributes == [:])
        #expect(mockBucketeerClient.currentUser()?.id == "targetingKey")

        let newContextWithAttr = MutableContext(
            targetingKey: "targetingKey",
            structure: MutableStructure(
                attributes: ["key": .string("value")]
            ))
        try await provider.onContextSet(oldContext: initContext, newContext: newContextWithAttr)
        #expect(mockBucketeerClient.userAttributes == ["key": "value"])

        let newContextEmptyAttr = MutableContext(
            targetingKey: "targetingKey",
            structure: MutableStructure(
                attributes: [:]
            ))
        try await provider.onContextSet(oldContext: newContextWithAttr, newContext: newContextEmptyAttr)
        #expect(mockBucketeerClient.userAttributes == [:])
    }
}
