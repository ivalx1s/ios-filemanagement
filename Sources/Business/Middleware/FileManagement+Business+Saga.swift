import Foundation

public protocol IFileManagementErrorHandler {
    func send(_ err: Error) async
}

public protocol IFileManagementSaga: PerduxSaga {}

extension FileManagement.Business {
    public actor Saga {
        private let fileService: IFileManagementService
        private let errorHandler: IFileManagementErrorHandler

        public init(
            fileService: IFileManagementService,
            errorHandler: IFileManagementErrorHandler
        ) {
            self.fileService = fileService
            self.errorHandler = errorHandler
        }
    }
}

extension FileManagement.Business.Saga: IFileManagementSaga {
    public func apply(_ effect: PerduxEffect) async {
        switch effect as? FileManagement.Business.Effect {
        case let .obtainFile(fromUrl, cachePolicy):
            await obtainFile(from: fromUrl, with: cachePolicy)
        case .none:
            break
        }
    }
}

extension FileManagement.Business.Saga {
    private func obtainFile(from url: URL, with policy: FileManagement.Business.Model.CachePolicy) async {
        switch await fileService.getFileContent(from: url, with: policy) {
        case let .success(localUrl):
            await action {
                FileManagement.Business.Action.fileLoadSucceed(remoteUrl: url, localUrl: localUrl)
            }
        case let .failure(err):
            await errorHandler.send(err)
            await actions(.concurrently) {
                FileManagement.Business.Action.fileLoadFailed(remoteUrl: url)
            }
        }
    }
}
