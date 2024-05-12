import Foundation
import Relux

extension FileManagement.Business {
    public enum Effect: ReluxEffect {
        case obtainUnprotectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always)
        case obtainProtectedFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always)
    }
}
