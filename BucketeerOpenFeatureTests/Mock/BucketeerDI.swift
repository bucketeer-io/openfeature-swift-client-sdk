import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

typealias OnDestroyCallback = (() -> Void)

class MockBucketeerDI: BucketeerDI {

    let client: MockBucketeerClient
    var user: BKTUser!
    var config: Bucketeer.BKTConfig!

    var onDestroy: OnDestroyCallback?
    var onInitializeError: BKTError?

    init(client: MockBucketeerClient) {
        self.client = client
    }

    func destroy() {
        onDestroy?()
    }

    func initialize(config: Bucketeer.BKTConfig, user: Bucketeer.BKTUser) async throws {
        self.config = config
        self.user = user
        client.mockCurrentUser = user
        client.userAttributes = user.attr
        if let error = onInitializeError {
            throw error
        }
    }

    func getClient() throws -> any BucketeerOpenFeature.BucketeerProtocol {
        return client
    }
}

class MockBucketeerClient: BucketeerProtocol {

    var mockBoolValue: Bucketeer.BKTEvaluationDetails<Bool>?
    var mockIntValue: Bucketeer.BKTEvaluationDetails<Int>?
    var mockDoubleValue: Bucketeer.BKTEvaluationDetails<Double>?
    var mockStringValue: Bucketeer.BKTEvaluationDetails<String>?
    var mockObjectValue: Bucketeer.BKTEvaluationDetails<Bucketeer.BKTValue>?
    var mockCurrentUser: Bucketeer.BKTUser?
    var userAttributes: [String: String]?

    func boolVariationDetails(featureId: String, defaultValue: Bool) -> Bucketeer.BKTEvaluationDetails<Bool> {
        return mockBoolValue!
    }

    func intVariationDetails(featureId: String, defaultValue: Int) -> Bucketeer.BKTEvaluationDetails<Int> {
        return mockIntValue!
    }

    func doubleVariationDetails(featureId: String, defaultValue: Double) -> Bucketeer.BKTEvaluationDetails<Double> {
        return mockDoubleValue!
    }

    func stringVariationDetails(featureId: String, defaultValue: String) -> Bucketeer.BKTEvaluationDetails<String> {
        return mockStringValue!
    }

    func objectVariationDetails(featureId: String,
                                defaultValue: Bucketeer.BKTValue)
    -> Bucketeer.BKTEvaluationDetails<Bucketeer.BKTValue> {
        return mockObjectValue!
    }

    func currentUser() -> Bucketeer.BKTUser? {
        return mockCurrentUser
    }

    func updateUserAttributes(attributes: [String: String]) {
        userAttributes = attributes
    }
}
