import Foundation

extension FileManagement.Data.Fetcher {
    public enum Err: Error {
        case unauthorized(cause: Error)
        case loadFailed(cause: Error)
        case loadFailed_noData
    }
}
