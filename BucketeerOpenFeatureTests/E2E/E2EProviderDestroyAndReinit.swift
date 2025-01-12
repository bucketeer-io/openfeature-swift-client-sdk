import XCTest
import Foundation
import Bucketeer
import OpenFeature
import Combine
@testable import BucketeerOpenFeature

final class E2EProviderDestroyAndReinitializeTests: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "bucketeer_user_evaluations_id")
    }

    override func tearDownWithError() throws {
        OpenFeatureAPI.shared.clearProvider()
    }

    func testDestroyAndReinitialize() async throws {
        try await autoReleaseScope()

        try await requiredStatusClientNotReady()

        try await autoReleaseScope()

        try await requiredStatusClientNotReady()
    }

    func requiredStatusClientNotReady() async throws {
        // Sleep 0.1 seconds because the provider is running in private queue. We are not able to access that queue.
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(OpenFeatureAPI.shared.getProviderStatus(), .notReady)

        XCTAssertThrowsError(try BKTClient.shared) { error in
            XCTAssertEqual(error as? BKTError, BKTError.illegalState(message: "BKTClient is not initialized"))
        }
    }

    func autoReleaseScope() async throws {

        let config = try BKTConfig.e2e()
        let provider = BucketeerProvider(config: config)

        let context = MutableContext(
            targetingKey: Constant.userId,
            structure: MutableStructure(
                attributes: [:]
            )
        )

        // Set context before initialize
        await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
        // Assert
        XCTAssertEqual(OpenFeatureAPI.shared.getProviderStatus(), .ready)

        // Check user attributes
        XCTAssertEqual(provider.client?.currentUser()?.attr, [:])
        XCTAssertEqual(provider.client?.currentUser()?.id, Constant.userId)

        // Sleep 0.1 seconds because the provider is running in private queue. We are not able to access that queue.
        try await Task.sleep(nanoseconds: 100_000_000)

        OpenFeatureAPI.shared.clearProvider()
    }
}
