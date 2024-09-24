import Foundation
import Relux

extension FileManagement.Business {
    public actor State: Relux.State {
        @Published public var localFiles: [Model.RemoteURL: Model.LoadingState] = [:]

        public init() {}

        public func reduce(with action: Relux.Action) async {
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
