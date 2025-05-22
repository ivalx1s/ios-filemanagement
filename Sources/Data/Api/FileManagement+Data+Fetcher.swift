import Foundation
import HttpClient

extension FileManagement.Data {
    public protocol IFetcher: Sendable {
        func loadUnprotectedFile(from url: URL, retrys: RequestRetrys?) async -> Result<Data, FileManagement.Business.Err>
        func loadProtectedFile(from url: URL, retrys: RequestRetrys?) async -> Result<Data, FileManagement.Business.Err>
    }
}

extension FileManagement.Data {
    public actor Fetcher: FileManagement.Data.IFetcher {
        public typealias Err = FileManagement.Business.Err
        private let client: IRpcAsyncClient
        private let headersProvider: FileManagement.Data.IApiHeadersProvider
        private let encoder: JSONEncoder = .init()
        private let decoder: JSONDecoder = .init()

        public init(
            client: IRpcAsyncClient,
            headersProvider: FileManagement.Data.IApiHeadersProvider
        ) {
            self.client = client
            self.headersProvider = headersProvider
        }

        public func loadUnprotectedFile(
            from url: URL,
            retrys: RequestRetrys?
        ) async -> Result<Data, Err> {
            let result = await client.get(
                url: url,
                headers: [:],
                retrys: retrys ?? (count: 0, delay: { 0 }),
                fileID: #fileID,
                functionName: #function,
                lineNumber: #line
            )

            switch result {
            case let .success(response):
                switch response.data {
                case let .some(data): return .success(data)
                case .none: return .failure(.loadFailed_noData)
                }
            case let .failure(err):
                switch err.responseCode {
                case 401: return .failure(.unauthorized(cause: err))
                default: return .failure(.loadFailed(cause: err))
                }
            }
        }

        public func loadProtectedFile(
            from url: URL,
            retrys: RequestRetrys?
        ) async -> Result<Data, Err> {
            switch await headersProvider.apiHeaders() {
                case let .success(headers):
                    switch await client.get(
                        url: url,
                        headers: headers,
                        retrys: retrys ?? (count: 0, delay: { 0 }),
                        fileID: #fileID,
                        functionName: #function,
                        lineNumber: #line
                    ) {
                        case let .success(response):
                            switch response.data {
                            case let .some(data): return .success(data)
                            case .none: return .failure(.loadFailed_noData)
                            }
                        case let .failure(err):
                            return .failure(.loadFailed(cause: err))
                    }
                case let .failure(err):
                    return .failure(err)
            }
        }
    }
}
