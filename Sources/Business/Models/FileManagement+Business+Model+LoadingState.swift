import Foundation

extension FileManagement.Business.Model {
    public enum LoadingState: Sendable {
        case loaded(localUrl: LocalURL)
        case failed(err: FileManagement.Business.Err)
    }
}

extension FileManagement.Business.Model.LoadingState {
    public var asUrl: URL? {
        switch self {
            case .failed: .none
            case let .loaded(localUrl): localUrl
        }
    }
}
