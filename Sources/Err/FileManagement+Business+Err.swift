import Foundation

extension FileManagement.Business {
    public enum Err: Error {
        case notImplemented
        case unauthorized(cause: Error)
        case loadFailed(cause: Error)
        case loadFailed_noData
    }
}
