import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

typealias OnInitializeCallback = ((Bucketeer.BKTConfig,
                                   Bucketeer.BKTUser,
                                   (((any BucketeerProtocol)?, Bucketeer.BKTError?) -> Void)) -> Void)
typealias OnDestroyCallback = (() -> Void)

class MockBucketeerDI: BucketeerDI {

    let client: MockBucketeerClient

    let onDestroy: OnDestroyCallback?
    let onInitialize: OnInitializeCallback?

    init(client: MockBucketeerClient, onDestroy: OnDestroyCallback? = nil, onInitialize: OnInitializeCallback? = nil) {
        self.client = client
        self.onDestroy = onDestroy
        self.onInitialize = onInitialize
    }

    func destroy() {
        onDestroy?()
    }

    func initialize(config: Bucketeer.BKTConfig,
                    user: Bucketeer.BKTUser,
                    completion: @escaping (((any BucketeerProtocol)?, Bucketeer.BKTError?) -> Void)) throws {
        onInitialize?(config, user, completion)
    }
}

class MockBucketeerClient: BucketeerProtocol {

    var mockBoolValue: Bucketeer.BKTEvaluationDetails<Bool>?
    var mockIntValue: Bucketeer.BKTEvaluationDetails<Int>?
    var mockDoubleValue: Bucketeer.BKTEvaluationDetails<Double>?
    var mockStringValue: Bucketeer.BKTEvaluationDetails<String>?
    var mockObjectValue: Bucketeer.BKTEvaluationDetails<Bucketeer.BKTValue>?
    var mockCurrentUser: Bucketeer.BKTUser?
    var onUserAttributesUpdate: (([String: String]) -> Void)?

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
        onUserAttributesUpdate?(attributes)
    }
}
