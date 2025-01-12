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

extension BKTValue {
    func toOpenFeatureValue() -> Value {
        switch self {
        case .boolean(let raw):
            return .boolean(raw)
        case .string(let raw):
            return .string(raw)
        case .number(let raw):
            return .double(raw)
        case .list(let raw):
            return .list(raw.map({ $0.toOpenFeatureValue()}))
        case .dictionary(let raw):
            return .structure(raw.mapValues({ $0.toOpenFeatureValue()}))
        case .null:
            return .null
        }
    }
}

extension Value {
    func toBKTValue() -> BKTValue {
        switch self {
        case .boolean(let raw):
            return .boolean(raw)
        case .string(let raw):
            return .string(raw)
        case .double(let raw):
            return .number(raw)
        case .list(let raw):
            return .list(raw.map({ $0.toBKTValue() }))
        case .structure(let raw):
            return .dictionary(raw.mapValues({ $0.toBKTValue() }))
        case .null:
            return .null
        case .integer(let raw):
            return .number(Double(raw))
        case .date(let raw):
            return .number(raw.timeIntervalSince1970)
        }
    }
}
