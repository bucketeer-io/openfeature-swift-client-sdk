import Bucketeer
import OpenFeature
import Combine

public class BucketeerProvider: FeatureProvider {
    private let eventHandler = EventHandler()

    public func observe() -> AnyPublisher<OpenFeature.ProviderEvent?, Never> {
        return eventHandler.observe()
    }

    public var hooks: [any Hook] = []
    public var metadata: ProviderMetadata = Metadata()

    private let config: BKTConfig

    private let diContainer: BucketeerDI!
    var client: BucketeerProtocol?

    public convenience init(
        config: BKTConfig
    ) {
        self.init(diContainer: BucketeerDIContainer(), config: config)
    }

    /// Internal initialization of BucketeerProvider. Required for testing purpose.
    init(diContainer: BucketeerDI, config: BKTConfig) {
        self.diContainer = diContainer
        self.config = config
    }

    deinit {
        diContainer.destroy()
    }

    /// Called by OpenFeatureAPI whenever the new Provider is registered
    public func initialize(initialContext: (any EvaluationContext)?) async throws {
        let user = try (initialContext ?? MutableContext()).toBKTUser()
        do {
            try await diContainer.initialize(
                config: config,
                user: user
            )
        } catch {
            if let error = error as? BKTError, case .timeout = error {
                // Its okay if the error is timed out. It only means the cache is not update yet.
                // But the cache will be updated in the background automatically.
            } else {
                // faltar error
                throw OpenFeatureError.providerFatalError(message: error.localizedDescription)
            }
        }

        do {
            let client = try diContainer.getClient()
            self.client = client
        } catch {
            throw OpenFeatureError.providerFatalError(message: error.localizedDescription)
        }
    }

    /// Called by OpenFeatureAPI whenever the context is changed
    /// Checks if the user attributes have changed and updates the
    /// attributes in the Bucketeer client accordingly.
    ///
    /// Note:
    /// - Changing the user ID is not supported in the current implementation.
    /// - To handle a user ID change, the BucketeerProvider must be remove and reinitialized.
    public func onContextSet(
        oldContext: (any EvaluationContext)?,
        newContext: any EvaluationContext
    ) async throws {
        // We should check if the user attributes has been changed
        // to update the user attributes in the Bucketeer client.
        let client = try requiredClient()
        guard let currentUser = client.currentUser() else {
            throw OpenFeatureError.providerNotReadyError
        }
        let user = try newContext.toBKTUser()
        // Not support for changing user id,
        guard currentUser.id == user.id else {
            throw OpenFeatureError.invalidContextError
        }
        client.updateUserAttributes(attributes: user.attr)
    }

    public func getBooleanEvaluation(
        key: String,
        defaultValue: Bool,
        context: (any EvaluationContext)?)
    throws -> ProviderEvaluation<Bool> {
        let client = try requiredClient()
        let evaluationDetails = client.boolVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    public func getStringEvaluation(
        key: String,
        defaultValue: String,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<String> {
        let client = try requiredClient()
        let evaluationDetails = client.stringVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    public func getIntegerEvaluation(
        key: String,
        defaultValue: Int64,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Int64> {
        let client = try requiredClient()
        // on 64-bit platforms like iOS, `Int` is the same size as `Int64`
        let evaluationDetails = client.intVariationDetails(featureId: key, defaultValue: Int(defaultValue))
        return evaluationDetails.toProviderEvaluation()
    }

    public func getDoubleEvaluation(
        key: String,
        defaultValue: Double,
        context: (any EvaluationContext)?
    ) throws -> ProviderEvaluation<Double> {
        let client = try requiredClient()
        let evaluationDetails = client.doubleVariationDetails(featureId: key, defaultValue: defaultValue)
        return evaluationDetails.toProviderEvaluation()
    }

    public func getObjectEvaluation(
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
