import Foundation
import Relux

extension FileManagement.Business {
    public enum Effect: Relux.Effect {
        case obtainUnprotectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always)
        case obtainProtectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always)
        case cleanup(directory: FileManager.SearchPathDirectory? = .none)
    }
}
