import Foundation
import Relux

extension FileManagement.UI {
    @MainActor
    public class ViewState: ObservableObject, Relux.Presentation.StatePresenting {
        public typealias RemoteURL = FileManagement.Business.Model.RemoteURL
        public typealias LocalURL = FileManagement.Business.Model.LocalURL
        public typealias LoadingState = FileManagement.Business.Model.LoadingState

        @Published public var localFiles: [RemoteURL: LoadingState] = [:]

        public init(fileState: FileManagement.Business.State) {
            Task { await initPipelines(fileState: fileState) }
        }
    }
}

extension FileManagement.UI.ViewState {
    private func initPipelines(fileState: FileManagement.Business.State) async {
        await fileState.$localFiles
            .receive(on: DispatchQueue.main)
            .assign(to: &$localFiles)
    }
}
