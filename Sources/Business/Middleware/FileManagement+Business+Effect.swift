import Foundation
import Relux
import HttpClient

extension FileManagement.Business {
    public enum Effect: Relux.Effect {
        case obtainUnprotectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always, retrys: RequestRetrys? = .none)
        case obtainProtectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always, retrys: RequestRetrys? = .none)
        case cleanup(directory: FileManager.SearchPathDirectory? = .none)
    }
}
