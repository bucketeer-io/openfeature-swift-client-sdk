import Bucketeer
import OpenFeature
import Combine

class BucketeerProvider: FeatureProvider {
    private let eventHandler = EventHandler(ProviderEvent.notReady)
    var hooks: [any Hook] = []
    var metadata: ProviderMetadata = Metadata()

    private let config: BKTConfig
    private let user: BKTUser

    public init(
        config: BKTConfig,
        user: BKTUser
    ) {
        self.config = config
        self.user = user
    }

    /// Called by OpenFeatureAPI whenever the new Provider is registered
    func initialize(initialContext: (any EvaluationContext)?) {
        do {
            try BKTClient.initialize(
                config: config,
                user: user
            ) { error in
                if let error = error {
                    if case .timeout = error {
                        self.eventHandler.send(.ready)
                    } else {
                        self.eventHandler.send(.error)
                    }
                    return
                }
                self.eventHandler.send(.ready)
            }

        } catch {
            // OpenFeatureError .providerFatarError(message: error.localizedDescription
            self.eventHandler.send(.error)
        }
    }

    func onContextSet(oldContext: (any EvaluationContext)?, newContext: any EvaluationContext) {

    }

    func getBooleanEvaluation(
        key: String,
        defaultValue: Bool,
        context: (any EvaluationContext)?)
    throws -> ProviderEvaluation<Bool> {
        let client = try BKTClient.shared
        let evaluationDetails = client.boolVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getStringEvaluation(
        key: String,
        defaultValue: String,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<String> {
        let client = try BKTClient.shared
        let evaluationDetails = client.stringVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getIntegerEvaluation(
        key: String,
        defaultValue: Int64,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Int64> {
        let client = try BKTClient.shared
        // on 64-bit platforms like iOS, `Int` is the same size as `Int64`
        let evaluationDetails = client.intVariationDetails(featureId: key, defaultValue: Int(defaultValue))
        return evaluationDetails.toProviderEvaluation()
    }

    func getDoubleEvaluation(
        key: String,
        defaultValue: Double,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Double> {
        let client = try BKTClient.shared
        let evaluationDetails = client.doubleVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getObjectEvaluation(
        key: String,
        defaultValue: Value,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Value> {
        let client = try BKTClient.shared
        let bktDefaultValue = defaultValue.toBKTValue()
        let evaluationDetails = client.objectVariationDetails(featureId: key, defaultValue: bktDefaultValue)
        let shouldUseOpenFeatureDefaultValue = bktDefaultValue == evaluationDetails.variationValue
        // If the value is the same as the default value, it indicates that the feature flag was not found,
        // and the default value was used. In this case, we should return the default value to OpenFeature.

        // Why we need overrideValue: there are differences between BKTValue and OpenFeatureValue.
        // BKTValue does not support .int64 and .date types, so we need to convert the BKTValue to Value.
        // However, for the default value, we can directly return it without additional conversion.
        return evaluationDetails.toProviderEvaluation(
            overrideValue: shouldUseOpenFeatureDefaultValue ? defaultValue : nil
        )
    }

    func observe() -> AnyPublisher<ProviderEvent, Never> {
        return eventHandler.observe()
    }
}

struct Metadata: ProviderMetadata {
    var name: String? = "Bucketeer Feature Flag Provider"
}
