import Foundation

public extension FileManagement.Business.Model {
    typealias LocalURL = URL
    typealias RemoteURL = URL
}

public extension FileManagement.Business.Model.RemoteURL {
    var asFileName: String {
        self.description.toBase64
    }
}
