import Foundation
import HttpClient

extension FileManagement.Business {
    public protocol IErrorHandler {
        func send(_ err: Error) async
    }
}

extension FileManagement.Data {
    public protocol IApiHeadersProvider {
        func apiHeaders() async -> Result<Headers, FileManagement.Business.Err>
    }
}

