import Bucketeer

final class MockLogger: BKTLogger {

    func debug(message: String) {
        print("Test Logger [DEBUG] \(message)")
    }

    func warn(message: String) {
        print("Test Logger [WARN] \(message)")
    }

    func error(_ error: Error) {
        print("Test Logger [ERROR] \(error)")
    }
}
