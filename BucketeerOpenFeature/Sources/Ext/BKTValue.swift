import Bucketeer
import OpenFeature

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
