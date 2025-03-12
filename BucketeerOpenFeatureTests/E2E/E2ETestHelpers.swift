import Foundation
import XCTest
@testable import Bucketeer

@available(iOS 13, *)
extension BKTConfig {
    static func e2e(featureTag: String = Constant.featureTag) throws -> BKTConfig {
        let apiKey = ProcessInfo.processInfo.environment["E2E_API_KEY"]!
        let apiEndpoint = ProcessInfo.processInfo.environment["E2E_API_ENDPOINT"]!

        let builder = BKTConfig.Builder()
            .with(apiKey: apiKey)
            .with(apiEndpoint: apiEndpoint)
            .with(featureTag: featureTag)
            .with(appVersion: "1.2.3")
            .with(logger: E2ELogger())

        return try builder.build()
    }
}

final class E2ELogger: BKTLogger {
    private var prefix: String {
        "Bucketeer E2E "
    }

    func debug(message: String) {
        print("\(prefix)[DEBUG] \(message)")
    }

    func warn(message: String) {
        print("\(prefix)[WARN] \(message)")
    }

    func error(_ error: Error) {
        print("\(prefix)[ERROR] \(error)")
    }
}
