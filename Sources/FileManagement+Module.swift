import Foundation
import HttpClient
import Relux

extension FileManagement {
    @MainActor
    public final class Module: Relux.Module {
        public let states: [any Relux.State]
        public let uistates: [any Relux.Presentation.StatePresenting]
        public let sagas: [any Relux.Saga]
        public let routers: [any Relux.Navigation.RouterProtocol]

        public let fileSystemManager: IFileSystemManager
        public let fetcher: FileManagement.Data.IFetcher
        public let service: FileManagement.Business.IService

        public init(
            fileManager: FileManager = .default,
            defaultCacheDestination: FileManager.SearchPathDirectory = .cachesDirectory,
            rpcClient: IRpcClient,
            apiHeadersProvider: FileManagement.Data.IApiHeadersProvider,
            errorHandler: FileManagement.Business.IErrorHandler
        ) {
            self.fileSystemManager = FileManagement.Data.FileSystemManager(
                fileManager: fileManager
            )
            self.fetcher = FileManagement.Data.Fetcher(
                client: rpcClient,
                headersProvider: apiHeadersProvider
            )

            self.service = FileManagement.Business.Service(
                fetcher: fetcher,
                fileManager: fileSystemManager,
                defaultCacheDestination: defaultCacheDestination
            )

            let state = FileManagement.Business.State()
            self.states = [state]

            let viewState = FileManagement.UI.ViewState(fileState: state)
            self.uistates = [viewState]

            self.routers = []

            let saga: FileManagement.Business.ISaga = FileManagement.Business.Saga(
                fileService: service,
                errorHandler: errorHandler
            )

            self.sagas = [saga]
        }
    }
}
