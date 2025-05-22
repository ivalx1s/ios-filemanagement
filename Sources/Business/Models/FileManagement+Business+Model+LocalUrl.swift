import Foundation

public extension FileManagement.Business.Model {
    typealias LocalURL = URL
    typealias RemoteURL = URL
}

public extension FileManagement.Business.Model.RemoteURL {
    var asFileName: String {
        let allowedCharacters = CharacterSet.alphanumerics.union(.init(charactersIn: "-_"))
        let pathExtension = self.pathExtension

        let url = pathExtension.isEmpty
            ? self.absoluteString
            : String(self.absoluteString.dropLast(pathExtension.count + 1))

        let filteredUrl = url.unicodeScalars
            .compactMap { allowedCharacters.contains($0) ? String($0) : .none }
            .joined()

        guard pathExtension.isNotEmpty else { return filteredUrl }
        return "\(filteredUrl).\(pathExtension)"
    }
}
