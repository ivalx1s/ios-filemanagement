import SwiftUI
import Relux

extension FileManagement.UI {
    public struct ImageContainer<PlaceholderView: View, ErorrStateView: View>: View {
        public typealias RemoteURL = FileManagement.Business.Model.RemoteURL
        @EnvironmentObject private var fileState: FileManagement.UI.ViewState

        private let url: RemoteURL
        private let protectionType: ProtectionType
        private let placeholderView: () -> PlaceholderView
        private let errorStateView: () -> ErorrStateView

        public init(
            url: RemoteURL,
            protectionType: ProtectionType,
            @ViewBuilder placeholderView: @escaping () -> PlaceholderView = { EmptyView() },
            @ViewBuilder errorStateView: @escaping() -> ErorrStateView = { EmptyView() }
        ) {
            self.url = url
            self.protectionType = protectionType
            self.placeholderView = placeholderView
            self.errorStateView = errorStateView
        }

        public var body: some View {
            content
                .task { await loadImage() }
        }

        @ViewBuilder
        private var content: some View {
            switch fileState.localFiles[url] {
                case .none: asyncImg(url: .none)
                case .failed: errorStateView()
                case let .loaded(url): asyncImg(url: url)
            }
        }

        private func asyncImg(url: URL?) -> some View {
            AsyncImage(url: url) { phase in
                switch phase {
                    case .empty: placeholderView()
                    case let .success(img): img.resizable()
                    case .failure: errorStateView()
                    @unknown default: ProgressView()
                }
            }
            .aspectRatio(contentMode: .fit)
        }
    }
}

extension FileManagement.UI.ImageContainer {
    private func loadImage() async {
        if fileState.localFiles[url].isNil {
            switch protectionType {
            case .protected:
                await action {
                    FileManagement.Business.Effect.obtainProtectedFile(fromUrl: url)
                }
            case .unprotected:
                await action {
                    FileManagement.Business.Effect.obtainUnprotectedFile(fromUrl: url)
                }
            }
        }
    }
}
