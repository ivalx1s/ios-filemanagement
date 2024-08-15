import Foundation
import Relux

extension FileManagement.Business.State {
    func _reduce(with action: FileManagement.Business.Action) async {
        switch action {
            case let .fileLoadSucceed(remote, local):
                self.localFiles[remote] = .loaded(localUrl: local)
            case let .fileLoadFailed(remote, err):
                self.localFiles[remote] = .failed(err: err)
        }
    }
}
