import Foundation

extension FileManagement.Business.State {
    func _reduce(with action: FileManagement.Business.Action) async {
        switch action {
        case let .fileLoadSucceed(remote, local):
            self.localFiles[remote] = local
        case .fileLoadFailed:
            break
        }
    }
}
