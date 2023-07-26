import Foundation

extension FileManagement.UI {
    @MainActor
    public class ViewState: PerduxViewState {
        public typealias RemoteURL = FileManagement.Business.Model.RemoteURL
        public typealias LocalURL = FileManagement.Business.Model.LocalURL

        @Published public var localFiles: [RemoteURL: LocalURL] = [:]

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
