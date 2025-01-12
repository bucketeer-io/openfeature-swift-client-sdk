import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("Init Provider Tests")
struct ProviderInitTests {

    let mockBucketeerClient: MockBucketeerClient
    let mockBucketeerDI: MockBucketeerDI
    let config: BKTConfig

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
    }

    @Test("Initialize fail because nil context")
    func initializeFailWithNilContext() async throws {
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        await #expect(
            throws: OpenFeatureError.targetingKeyMissingError,
            "Initialization should fail with nil context",
            performing: {
                try await provider.initialize(initialContext: nil)
        })
    }

    @Test("Initialize fail because missing targeting key")
    func initializeFailMissingTargetingKey() async throws {
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        let context = MutableContext(
            structure: MutableStructure(
                attributes: [:]
            )
        )
        await #expect(
            throws: OpenFeatureError.targetingKeyMissingError,
            "Initialization should fail with missing targeting key",
            performing: {
                try await provider.initialize(initialContext: nil)
        })
    }

    @Test func initializeFailWithError() async throws {
        mockBucketeerDI.onInitializeError = BKTError.forbidden(message: "Forbidden")
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        await #expect(
            throws: OpenFeatureError.providerFatalError(message: "Forbidden"),
            performing: {
                try await provider.initialize(initialContext: MutableContext(
                    targetingKey: "targetingKey",
                    structure: MutableStructure(
                        attributes: [:]
                    )
                ))
        })
    }

    @Test func notReadyProviderStatus() async throws {
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        #expect(throws: OpenFeatureError.providerNotReadyError, performing: {
            _ = try provider.getBooleanEvaluation(key: "key", defaultValue: true, context: nil)
        })
    }

    @Test func initializeSuccess() async throws {
        let context = MutableContext(
            targetingKey: "targetingKey",
            structure: MutableStructure(
                attributes: [:]
            )
        )
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        // Act
        try await provider.initialize(initialContext: context)

        // Assert
        #expect(mockBucketeerDI.user.attr == [:])
        #expect(mockBucketeerDI.user.id == "targetingKey")
    }

    @Test func initializeSuccessButReceievedTimeoutError() async throws {
        mockBucketeerDI.onInitializeError = BKTError.timeout(
            message: "Timeout",
            error: NSError(domain: "timeout", code: -1),
            timeoutMillis: 100
        )
        let context = MutableContext(
            targetingKey: "targetingKey",
            structure: MutableStructure(
                attributes: [:]
            )
        )
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        // Act
        try await provider.initialize(initialContext: context)

        // Assert
        #expect(mockBucketeerDI.user.attr == [:])
        #expect(mockBucketeerDI.user.id == "targetingKey")
    }
}
