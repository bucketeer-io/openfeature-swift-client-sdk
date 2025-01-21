import Bucketeer
import OpenFeature

extension BKTEvaluationDetails where T == BKTValue {
    func toProviderEvaluation(overrideValue: Value? = nil) -> ProviderEvaluation<Value> {
        return ProviderEvaluation<Value>(
            value: overrideValue ?? self.variationValue.toOpenFeatureValue(),
            flagMetadata: [:],
            variant: nil,
            reason: self.reason.rawValue)
    }
}

extension BKTEvaluationDetails where T: Equatable {
    func toProviderEvaluation() -> ProviderEvaluation<T> {
        return ProviderEvaluation<T>(
            value: self.variationValue,
            flagMetadata: [:],
            variant: nil,
            reason: self.reason.rawValue)
    }
}

extension BKTEvaluationDetails where T == Int {
    func toProviderEvaluation() -> ProviderEvaluation<Int64> {
        return ProviderEvaluation<Int64>(
            value: Int64(self.variationValue),
            flagMetadata: [:],
            variant: nil,
            reason: self.reason.rawValue)
    }
}
