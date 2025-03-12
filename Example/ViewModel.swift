import Combine
import SwiftUI
import Foundation
import BucketeerOpenFeature
import OpenFeature
import Bucketeer

@MainActor
class ViewModel: ObservableObject {
    @Published var showNewFeature = false

    init() {
        Task {
            do {
                try await initialize()
                getEvaluation()
            } catch {
                print("GetEvaluation Error: \(error)")
            }
        }
    }

    func initialize() async throws {
        let userId = "targetingUserId"
        let config = try makeConfigUsingBuilder()
        let provider = BucketeerProvider(config: config)

        let context = MutableContext(
            targetingKey: userId,
            structure: MutableStructure(
                attributes: [:]
            )
        )

        // Set context before initialize
        await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
    }

    func getEvaluation() {
        let featureId = "new-feature"
        let evaluation = OpenFeatureAPI.shared.getClient().getBooleanValue(key: featureId, defaultValue: false)
        showNewFeature = evaluation
    }

    private func makeConfigUsingBuilder() throws -> BKTConfig {
        let bundle = Bundle(for: type(of: self))
        let apiEndpoint = "API_ENDPOINT"
        let apiKey = "API_KEY"
        let tag = "ios"
        let builder = BKTConfig.Builder()
            .with(apiKey: apiKey)
            .with(apiEndpoint: apiEndpoint)
            .with(featureTag: tag)
            .with(pollingInterval: 150_000)
            .with(appVersion: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
            .with(logger: AppLogger())

        return try builder.build()
    }
}
