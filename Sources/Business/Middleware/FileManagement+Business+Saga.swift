import Foundation
import Relux

public protocol IFileManagementSaga: ReluxSaga {}

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
    public func apply(_ effect: ReluxEffect) async {
        switch effect as? FileManagement.Business.Effect {
        case let .obtainUnprotectedFile(fromUrl, cachePolicy):
            await obtainFile(from: fromUrl, with: cachePolicy, apiProtected: false)
        case let .obtainProtectedFile(fromUrl, cachePolicy):
            await obtainFile(from: fromUrl, with: cachePolicy, apiProtected: true)
        case .none:
            break
        }
    }
}

extension FileManagement.Business.Saga {
    private func obtainFile(from url: URL, with policy: FileManagement.Business.Model.CachePolicy, apiProtected : Bool) async {
        switch await fileService.getFileContent(from: url, with: policy, apiProtected: apiProtected) {
        case let .success(localUrl):
            await action {
                FileManagement.Business.Action.fileLoadSucceed(remoteUrl: url, localUrl: localUrl)
            }
        case let .failure(err):
            await errorHandler.send(err)
            await actions(.concurrently) {
                FileManagement.Business.Action.fileLoadFailed(remoteUrl: url, err: err)
            }
        }
    }
}
