import Foundation

extension FileManagement.Business {
    public enum Err: Error {
        case unauthorized(cause: Error)
        case loadFailed(cause: Error)
    }
}
