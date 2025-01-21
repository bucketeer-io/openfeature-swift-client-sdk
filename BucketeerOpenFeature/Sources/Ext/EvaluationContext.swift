import Bucketeer
import OpenFeature

extension EvaluationContext {
    func toBKTUser() throws -> BKTUser {
        // We should convert the EvaluationContext to a BKTUser.
        do {
            let maps = self.asMap()
            let targetUserId = self.getTargetingKey()
            let attributes = maps.mapValues({ $0.toString() })
            let user = try BKTUser.Builder()
                .with(id: targetUserId)
                .with(attributes: attributes)
                .build()
            return user
        } catch {
            throw OpenFeatureError.targetingKeyMissingError
        }
    }
}
