import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("Init Provider Tests")
struct InitProviderTests {

    let mockBucketeerClient: MockBucketeerClient
    let mockBucketeerDI: MockBucketeerDI
    let config: BKTConfig
    let user: BKTUser

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
        user = try BKTUser.Builder().with(id: "user1").with(attributes: ["key": "value"]).build()
    }

    @Test("Initialize fail because nil context") func initializeFailWithNilContext() async throws {
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        // Act
        provider.initialize(initialContext: nil)

        // Assert
        _ = provider.observe().sink { #expect($0 == .error) }
    }

    @Test("Initialize fail because missing targeting key") func initializeFailMissingTargetingKey() async throws {
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        let context = MutableContext(
            structure: MutableStructure(
                attributes: [:]
            )
        )
        // Act
        provider.initialize(initialContext: context)

        // Assert
        _ = provider.observe().sink { #expect($0 == .error) }
    }

    @Test func initializeFailWithError() async throws {
        mockBucketeerDI.onInitializeError = BKTError.forbidden(message: "Forbidden")
        let provider = BucketeerProvider.init(diContainer: mockBucketeerDI, config: config)
        // Act
        provider.initialize(initialContext: nil)

        // Assert
        _ = provider.observe().sink { #expect($0 == .error) }
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
        provider.initialize(initialContext: context)
        // Assert
        _ = provider.observe().sink { #expect($0 == .ready) }
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
        provider.initialize(initialContext: context)
        // Assert
        _ = provider.observe().sink { #expect($0 == .ready) }
    }
}
