import Foundation

extension FileManagement.Business.Model {
    public enum CachePolicy {
        case never
        case lazy(cadence: PolicyCadence)
        case required(cadence: PolicyCadence)
        case always
    }
}

extension FileManagement.Business.Model.CachePolicy {
    public struct PolicyCadence {
        public let type: Cadence
        public let value: UInt
        
        public init(
            type: Cadence,
            value: UInt
        ) {
            self.type = type
            self.value = value
        }
    }
}
