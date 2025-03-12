import Foundation
import HttpClient

extension FileManagement.Business {
    public protocol IErrorHandler: Sendable {
        func send(_ err: Error) async
    }
}

extension FileManagement.Data {
    public protocol IApiHeadersProvider: Sendable {
        func apiHeaders() async -> Result<Headers, FileManagement.Business.Err>
    }
}

