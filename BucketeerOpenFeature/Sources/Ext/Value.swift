import Bucketeer
import OpenFeature

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

    func toString() -> String {
        switch self {
        case .boolean(let raw):
            return raw.description
        case .string(let raw):
            return raw
        case .double(let raw):
            return raw.description
        case .integer(let raw):
            return raw.description
        case .list(let raw):
            return raw.map { $0.toString() }.joined(separator: ", ")
        case .structure(let raw):
            return raw.sorted { $0.key < $1.key } // Sort keys alphabetically
                        .map { "\($0.key): \($0.value.toString())" }
                        .joined(separator: ", ")
        case .date(let raw):
            return raw.description
        case .null:
            return "null"
        }
    }
}
