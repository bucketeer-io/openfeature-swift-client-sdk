import Bucketeer
import Foundation

internal protocol BucketeerProtocol {
    func boolVariationDetails(featureId: String, defaultValue: Bool) -> BKTEvaluationDetails<Bool>

    func intVariationDetails(featureId: String, defaultValue: Int) -> BKTEvaluationDetails<Int>

    func doubleVariationDetails(featureId: String, defaultValue: Double) -> BKTEvaluationDetails<Double>

    func stringVariationDetails(featureId: String, defaultValue: String) -> BKTEvaluationDetails<String>

    func objectVariationDetails(featureId: String, defaultValue: BKTValue)
    -> BKTEvaluationDetails<BKTValue>

    func currentUser() -> BKTUser?

    func updateUserAttributes(attributes: [String: String])
}

// Do not change this extension implement as we don't want to override the original implementation
extension BKTClient: BucketeerProtocol {}

internal protocol BucketeerDI {
    func destroy()
    func initialize(
        config: BKTConfig,
        user: BKTUser
    ) async throws
    func getClient() throws -> any BucketeerProtocol
}

class BucketeerDIContainer: BucketeerDI {
    func destroy() {
        try? BKTClient.destroy()
    }

    func initialize(
        config: BKTConfig,
        user: BKTUser
    ) async throws {
        try await BKTClient.asyncInitialize(config: config, user: user)
    }

    func getClient() throws -> any BucketeerProtocol {
        return try BKTClient.shared
    }
}

@available(iOS 13, *)
extension BKTClient {
    static func asyncInitialize(config: BKTConfig, user: BKTUser, timeoutMillis: Int64 = 5000) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    try self.initialize(config: config, user: user, timeoutMillis: timeoutMillis) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
