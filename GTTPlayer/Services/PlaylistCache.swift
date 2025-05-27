// Service to cache playlists
import Foundation

class PlaylistCache {
    static let shared = PlaylistCache()
    private init() {}

    private let cacheKey = "cachedPlaylists"
    private let fileManager = FileManager.default
    private var cacheURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("m3u_cache.json")
    }

    func save(entries: [M3UEntry], for url: String) {
        var all = loadAll()
        all[url] = entries
        if let cacheURL = cacheURL, let data = try? JSONEncoder().encode(all) {
            try? data.write(to: cacheURL)
        }
    }

    func load(for url: String) -> [M3UEntry]? {
        let all = loadAll()
        return all[url]
    }

    func loadAll() -> [String: [M3UEntry]] {
        guard let cacheURL = cacheURL, let data = try? Data(contentsOf: cacheURL) else { return [:] }
        return (try? JSONDecoder().decode([String: [M3UEntry]].self, from: data)) ?? [:]
    }

    func clear() {
        if let cacheURL = cacheURL {
            try? fileManager.removeItem(at: cacheURL)
        }
    }
}
