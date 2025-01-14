import Bucketeer
import OpenFeature
import Combine

class BucketeerProvider: FeatureProvider {
    private let eventHandler = EventHandler(ProviderEvent.notReady)
    var hooks: [any Hook] = []
    var metadata: ProviderMetadata = Metadata()

    private let config: BKTConfig

    private let diContainer: BucketeerDI!
    private var client: BucketeerProtocol?

    public convenience init(
        builder: BKTConfig.Builder
    ) throws {
        do {
            try self.init(diContainer: BucketeerDIContainer(), builder: builder)
        } catch {
            throw OpenFeatureError.providerFatarError(message: error.localizedDescription)
        }
    }

    /// Internal initialization of BucketeerProvider. Required for testing purpose.
    init(diContainer: BucketeerDI, builder: BKTConfig.Builder) throws {
        self.diContainer = diContainer
        self.config = try builder.build()
    }

    deinit {
        diContainer.destroy()
    }

    /// Called by OpenFeatureAPI whenever the new Provider is registered
    func initialize(initialContext: (any EvaluationContext)?) {
        do {
            let user = try (initialContext ?? MutableContext()).toBKTUser()
            try diContainer.initialize(
                config: config,
                user: user
            ) { _, error in
                if let error = error {
                    if case .timeout = error {
                        // Its okay if the error is timed out. It only means the cache is not update yet.
                        // But the cache will be updated in the background automatically.
                        self.eventHandler.send(.ready)
                    } else {
                        self.eventHandler.send(.error)
                    }
                    return
                }
                self.eventHandler.send(.ready)
            }
        } catch {
            self.eventHandler.send(.error)
        }
    }

    func onContextSet(oldContext: (any EvaluationContext)?, newContext: any EvaluationContext) {
        // We should check if the user attributes has been changed
        // to update the user attributes in the Bucketeer client.
        do {
            let client = try requiredClient()
            guard let currentUser = client.currentUser() else {
                throw OpenFeatureError.providerNotReadyError
            }
            let user = try newContext.toBKTUser()
            // Not support for changing user id,
            // for changing user id, we need to reinitialize the Bucketeer client.
            guard currentUser.id == user.id else {
                throw OpenFeatureError.invalidContextError
            }

            client.updateUserAttributes(attributes: user.attr)
        } catch {
            eventHandler.send(.error)
        }
    }

    func getBooleanEvaluation(
        key: String,
        defaultValue: Bool,
        context: (any EvaluationContext)?)
    throws -> ProviderEvaluation<Bool> {
        let client = try requiredClient()
        let evaluationDetails = client.boolVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getStringEvaluation(
        key: String,
        defaultValue: String,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<String> {
        let client = try requiredClient()
        let evaluationDetails = client.stringVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getIntegerEvaluation(
        key: String,
        defaultValue: Int64,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Int64> {
        let client = try requiredClient()
        // on 64-bit platforms like iOS, `Int` is the same size as `Int64`
        let evaluationDetails = client.intVariationDetails(featureId: key, defaultValue: Int(defaultValue))
        return evaluationDetails.toProviderEvaluation()
    }

    func getDoubleEvaluation(
        key: String,
        defaultValue: Double,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Double> {
        let client = try requiredClient()
        let evaluationDetails = client.doubleVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    func getObjectEvaluation(
        key: String,
        defaultValue: Value,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Value> {
        let client = try requiredClient()
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

    private func requiredClient() throws -> BucketeerProtocol {
        guard let client = client else {
            throw OpenFeatureError.providerNotReadyError
        }
        return client
    }

}

struct Metadata: ProviderMetadata {
    var name: String? = "Bucketeer Feature Flag Provider"
}
