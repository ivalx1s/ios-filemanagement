import Foundation
import Relux

extension FileManagement.Business {
    public enum Action: ReluxAction {
        case fileLoadSucceed(remoteUrl: Model.RemoteURL, localUrl: Model.LocalURL)
        case fileLoadFailed(remoteUrl: Model.RemoteURL)
    }
}
