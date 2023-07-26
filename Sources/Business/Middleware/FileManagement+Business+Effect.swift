import Foundation

extension FileManagement.Business {
    public enum Effect: PerduxEffect {
        case obtainFile(fromUrl: URL, cachePolicy: Model.CachePolicy = .always)
    }
}
