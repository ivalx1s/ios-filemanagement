import Foundation
import HttpClient

extension FileManagement.Business {
    public protocol IService: Sendable {
        func getFileContent(
            from remoteUrl: FileManagement.Business.Model.RemoteURL,
            with cachePolicy: FileManagement.Business.Model.CachePolicy,
            apiProtected: Bool,
            retrys: RequestRetrys?
        ) async -> Result<FileManagement.Business.Model.LocalURL, FileManagement.Business.Err>

        func cleanup(searchPathDestination: FileManager.SearchPathDirectory) async
        func cleanup() async
    }
}

extension FileManagement.Business {
    public actor Service {
        public typealias CachePolicy = FileManagement.Business.Model.CachePolicy
        public typealias RemoteURL = FileManagement.Business.Model.RemoteURL
        public typealias LocalURL = FileManagement.Business.Model.LocalURL
        public typealias Err = FileManagement.Business.Err

        private let fetcher: FileManagement.Data.IFetcher
        private let fileManager: IFileSystemManager
        private let defaultCacheDestination: FileManager.SearchPathDirectory

        public init(
            fetcher: FileManagement.Data.IFetcher,
            fileManager: IFileSystemManager,
            defaultCacheDestination: FileManager.SearchPathDirectory = .cachesDirectory
        ) {
            self.fetcher = fetcher
            self.fileManager = fileManager
            self.defaultCacheDestination = defaultCacheDestination
        }
    }
}

extension FileManagement.Business.Service: FileManagement.Business.IService {
    public func getFileContent(
        from remoteUrl: RemoteURL,
        with cachePolicy: CachePolicy,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        switch cachePolicy {
        case .never:
            return await obtainWithNeverCachePolicy(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)

        case let .lazy(cadence):
            return await obtainWithLazyCachePolicy(from: remoteUrl, cadence: cadence, apiProtected: apiProtected, retrys: retrys)

        case let .required(cadence):
            return await obtainWithRequiredCachePolicy(from: remoteUrl, cadence: cadence, apiProtected: apiProtected, retrys: retrys)

        case .always:
            return await obtainWithAlwaysCachePolicy(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
        }
    }

    public func cleanup(searchPathDestination: FileManager.SearchPathDirectory) async {
        fileManager.cleanCache(for: searchPathDestination)
    }

    public func cleanup() async {
        await self.cleanup(searchPathDestination: defaultCacheDestination)
    }
}

extension FileManagement.Business.Service {
    private func obtainWithRequiredCachePolicy(
        from remoteUrl: RemoteURL,
        cadence: CachePolicy.PolicyCadence,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            switch fileManager.getFileDate(url: localUrl) {
            case let .some(date):
                switch isExpired(fileDate: date, currentDate: .now, cadence: cadence) {
                case true:
                    return await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
                case false:
                    return .success(localUrl)
                }

            case .none:
                return await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
            }
        case .none:
            return await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
        }
    }

    private func obtainWithLazyCachePolicy(
        from remoteUrl: RemoteURL,
        cadence: CachePolicy.PolicyCadence,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            switch fileManager.getFileDate(url: localUrl) {
            case let .some(date):
                switch isExpired(fileDate: date, currentDate: .now, cadence: cadence) {
                case true:
                    Task { await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys) }
                case false:
                    break
                }
                return .success(localUrl)
            case .none:
                Task { await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys) }
                return .success(localUrl)
            }
        case .none:
            return await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
        }
    }

    private func obtainWithNeverCachePolicy(
        from remoteUrl: RemoteURL,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
    }

    private func obtainWithAlwaysCachePolicy(
        from remoteUrl: RemoteURL,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            return .success(localUrl)
        case .none:
            return await fetchFileFromRemote(from: remoteUrl, apiProtected: apiProtected, retrys: retrys)
        }
    }

    private func isExpired(fileDate: Date, currentDate: Date, cadence: CachePolicy.PolicyCadence) -> Bool {
        let cadenceValue = cadence.value.asInt()
        switch cadence.type {
        case .years:
            return fileDate < currentDate.add(years: -cadenceValue)
        case .months:
            return fileDate < currentDate.add(months: -cadenceValue)
        case .weeks:
            return fileDate < currentDate.add(days: -cadenceValue * 7)
        case .days:
            return fileDate < currentDate.add(days: -cadenceValue)
        case .hours:
            return fileDate < currentDate.add(hours: -cadenceValue)
        case .minutes:
            return fileDate < currentDate.add(minutes: -cadenceValue)
        }
    }

    private func fetchFromLocal(from remoteUrl: RemoteURL) async -> LocalURL? {
        let path = fileManager.getFileLocationUrl(fileNameWithExtension: remoteUrl.asFileName, destination: defaultCacheDestination)
        switch fileManager.exists(url: path) {
        case let .some(url):
            return url
        case .none:
            return .none
        }
    }

    private func fetchFileFromRemote(
        from remoteUrl: RemoteURL,
        apiProtected: Bool,
        retrys: RequestRetrys?
    ) async -> Result<LocalURL, Err> {
        async let result = apiProtected
            ? fetcher.loadProtectedFile(from: remoteUrl, retrys: retrys)
            : fetcher.loadUnprotectedFile(from: remoteUrl, retrys: retrys)

        switch await result{
        case let .success(data):
                switch fileManager.createOrReplace(data: data, fileNameWithExtension: remoteUrl.asFileName, destination: defaultCacheDestination) {
            case let .success(url): return .success(url)
            case let .failure(err): return .failure(.loadFailed(cause: err))
            }
        case let .failure(err):
            return .failure(.loadFailed(cause: err))
        }
    }
}
