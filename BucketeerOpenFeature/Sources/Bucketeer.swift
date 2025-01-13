import Bucketeer

// BucketeerProtocol is use for testing purpose
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
    func destroy() throws
    func initialize(
        config: BKTConfig,
        user: BKTUser,
        timeoutMillis: Int64,
        completion: ((BKTError?) -> Void)) throws
}
