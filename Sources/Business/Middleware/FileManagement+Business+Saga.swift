import Foundation
import Relux

extension FileManagement.Business {
    public protocol ISaga: Relux.Saga {}
}

extension FileManagement.Business {
    public actor Saga {
        private let fileService: FileManagement.Business.IService
        private let errorHandler: FileManagement.Business.IErrorHandler

        public init(
            fileService: FileManagement.Business.IService,
            errorHandler: FileManagement.Business.IErrorHandler
        ) {
            self.fileService = fileService
            self.errorHandler = errorHandler
        }
    }
}

extension FileManagement.Business.Saga: FileManagement.Business.ISaga {
    public func apply(_ effect: Relux.Effect) async {
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
