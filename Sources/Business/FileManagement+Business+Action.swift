import Foundation

extension FileManagement.Business {
    public enum Action: PerduxAction {
        case fileLoadSucceed(remoteUrl: Model.RemoteURL, localUrl: Model.LocalURL)
        case fileLoadFailed(remoteUrl: Model.RemoteURL)
    }
}
