import Foundation

public protocol IFileManagementService {
    func getFileContent(
        from remoteUrl: FileManagement.Business.Model.RemoteURL,
        with cachePolicy: FileManagement.Business.Model.CachePolicy
    ) async -> Result<FileManagement.Business.Model.LocalURL, FileManagement.Business.Err>
}

extension FileManagement.Business {
    public actor Service {
        public typealias CachePolicy = FileManagement.Business.Model.CachePolicy
        public typealias RemoteURL = FileManagement.Business.Model.RemoteURL
        public typealias LocalURL = FileManagement.Business.Model.LocalURL
        public typealias Err = FileManagement.Business.Err

        private let fetcher: IFileManagementFetcher
        private let fileManager: IFileSystemManager
        private let cacheDestination: FileManager.SearchPathDirectory = .documentDirectory

        public init(
            fetcher: IFileManagementFetcher,
            fileManager: IFileSystemManager
        ) {
            self.fetcher = fetcher
            self.fileManager = fileManager
        }
    }
}

extension FileManagement.Business.Service: IFileManagementService {
    public func getFileContent(from remoteUrl: RemoteURL, with cachePolicy: CachePolicy) async -> Result<LocalURL, Err> {
        switch cachePolicy {
        case .never:
            return await obtainWithNeverCachePolicy(from: remoteUrl)

        case let .lazy(cadence):
            return await obtainWithLazyCachePolicy(from: remoteUrl, cadence: cadence)

        case let .required(cadence):
            return await obtainWithRequiredCachePolicy(from: remoteUrl, cadence: cadence)

        case .always:
            return await obtainWithAlwaysCachePolicy(from: remoteUrl)
        }
    }
}

extension FileManagement.Business.Service {
    private func obtainWithRequiredCachePolicy(from remoteUrl: RemoteURL, cadence: CachePolicy.PolicyCadence) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            switch fileManager.getFileDate(url: localUrl) {
            case let .some(date):
                switch isExpired(fileDate: date, currentDate: .now, cadence: cadence) {
                case true:
                    return await fetchFileFromRemote(from: remoteUrl)
                case false:
                    return .success(localUrl)
                }

            case .none:
                return await fetchFileFromRemote(from: remoteUrl)
            }
        case .none:
            return await fetchFileFromRemote(from: remoteUrl)
        }
    }

    private func obtainWithLazyCachePolicy(from remoteUrl: RemoteURL, cadence: CachePolicy.PolicyCadence) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            switch fileManager.getFileDate(url: localUrl) {
            case let .some(date):
                switch isExpired(fileDate: date, currentDate: .now, cadence: cadence) {
                case true:
                    Task { await fetchFileFromRemote(from: remoteUrl) }
                case false:
                    break
                }
                return .success(localUrl)
            case .none:
                Task { await fetchFileFromRemote(from: remoteUrl) }
                return .success(localUrl)
            }
        case .none:
            return await fetchFileFromRemote(from: remoteUrl)
        }
    }

    private func obtainWithNeverCachePolicy(from remoteUrl: RemoteURL) async -> Result<LocalURL, Err> {
        await fetchFileFromRemote(from: remoteUrl)
    }

    private func obtainWithAlwaysCachePolicy(from remoteUrl: RemoteURL) async -> Result<LocalURL, Err> {
        switch await fetchFromLocal(from: remoteUrl) {
        case let .some(localUrl):
            return .success(localUrl)
        case .none:
            return await fetchFileFromRemote(from: remoteUrl)
        }
    }

    private func isExpired(fileDate: Date, currentDate: Date, cadence: CachePolicy.PolicyCadence) -> Bool {
        let cadenceValue = cadence.value.asInt
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
        let path = fileManager.getFileLocationUrl(fileNameWithExtension: remoteUrl.asFileName, destination: cacheDestination)
        switch fileManager.exists(url: path) {
        case let .some(url):
            return url
        case .none:
            return .none
        }
    }

    private func fetchFileFromRemote(from remoteUrl: RemoteURL) async -> Result<LocalURL, Err> {
        switch await fetcher.loadFile(by: remoteUrl) {
        case let .success(data):
            switch fileManager.createOrReplace(data: data, fileNameWithExtension: remoteUrl.asFileName, destination: cacheDestination) {
            case let .success(url): return .success(url)
            case let .failure(err): return .failure(.loadFailed(cause: err))
            }
        case let .failure(err):
            return .failure(.loadFailed(cause: err))
        }
    }
}
