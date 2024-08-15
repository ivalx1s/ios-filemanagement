import Foundation
import Relux

extension FileManagement.Business {
    public actor State: ReluxState {
        @Published public var localFiles: [Model.RemoteURL: Model.LoadingState] = [:]

        public init() {}

        public func reduce(with action: ReluxAction) async {
            switch action as? Action {
            case let .some(action): await _reduce(with: action)
            case .none: break
            }
        }

        public func cleanup() async {
            self.localFiles = [:]
        }
    }
}
