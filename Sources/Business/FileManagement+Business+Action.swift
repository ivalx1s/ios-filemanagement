import Foundation
import Relux

extension FileManagement.Business {
    public enum Action: Relux.Action {
        case fileLoadSucceed(remoteUrl: Model.RemoteURL, localUrl: Model.LocalURL)
        case fileLoadFailed(remoteUrl: Model.RemoteURL, err: Err)
    }
}
