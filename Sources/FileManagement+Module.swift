import Foundation
import HttpClient
import Relux

extension FileManagement {
    @MainActor
    public final class Module: Relux.Module {
        public let fileSystemManager: IFileSystemManager
        public let fetcher: IFileManagementFetcher
        public let service: IFileManagementService
        
        public init(
            fileManager: FileManager = .default,
            rpcClient: IRpcClient,
            apiHeadersProvider: IFileManagementApiHeadersProvider,
            errorHandler: IFileManagementErrorHandler
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
                fileManager: fileSystemManager
            )
            
            let state = FileManagement.Business.State()
            let viewState = FileManagement.UI.ViewState(fileState: state)
            let saga: IFileManagementSaga = FileManagement.Business.Saga(
                fileService: service,
                errorHandler: errorHandler
            )
            
            super.init(
                states: [state],
                viewStates: [viewState],
                sagas: [saga]
            )
        }
    }
}
