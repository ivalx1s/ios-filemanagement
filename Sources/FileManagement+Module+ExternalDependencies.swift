import Foundation
import HttpClient

public protocol IFileManagementErrorHandler {
    func send(_ err: Error) async
}

public protocol IFileManagementApiHeadersProvider {
    func apiHeaders() async -> Result<Headers, FileManagement.Business.Err>
}
