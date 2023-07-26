import Foundation

extension FileManagement.Data.FileSystemManager {
    public enum Err: Error {
        case failedToReadFile_noUrl(nameWithExt: String)
        case failedToReadFile(path: URL, cause: Error)
        case failedToDeleteFile(path: URL, cause: Error)
        case failedToMoveFile(fromPath: URL, toPath: URL, cause: Error)
        case failedToCreateOrReplaceFile(path: URL, cause: Error)
    }
}
