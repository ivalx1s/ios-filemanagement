import Foundation

public extension FileManagement.Business.Model {
    typealias LocalURL = URL
    typealias RemoteURL = URL
}

public extension FileManagement.Business.Model.RemoteURL {
    var asFileName: String {
        let allowedCharacters = CharacterSet.alphanumerics.union(.init(charactersIn: "-_."))

        return self.absoluteString
            .unicodeScalars
            .filter(allowedCharacters.contains)
            .map { String($0) }
            .joined()
    }
}
