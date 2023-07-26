import Foundation
import RestClient

public protocol IFileManagementFetcher {
    func loadFile(by url: URL) async -> Result<Data, FileManagement.Data.Fetcher.Err>
}

extension FileManagement.Data {
    public actor Fetcher: IFileManagementFetcher {
        private let client: IRpcClient
        private let encoder: JSONEncoder = .init()
        private let decoder: JSONDecoder = .init()

        public init(client: IRpcClient) {
            self.client = client
        }

        public func loadFile(by url: URL) async -> Result<Data, FileManagement.Data.Fetcher.Err> {
            let result = await client.get(url: url)

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
    }
}
