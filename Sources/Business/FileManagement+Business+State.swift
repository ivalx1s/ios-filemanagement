import Foundation

extension FileManagement.Business {
    public actor State: PerduxState {
        @Published public var localFiles: [Model.RemoteURL: Model.LocalURL] = [:]

        public init() {}

        public func reduce(with action: PerduxAction) async {
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
