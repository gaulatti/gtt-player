// ViewModel for managing playlists
import Foundation
import Combine

class PlaylistViewModel: ObservableObject {
    @Published var playlistURLs: [String] = []
    @Published var playlists: [String: [M3UEntry]] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func addPlaylist(url: String) async {
        guard !playlistURLs.contains(url) else { return }
        isLoading = true
        errorMessage = nil
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            guard let str = String(data: data, encoding: .utf8) else { throw URLError(.badServerResponse) }
            let entries = M3UParser.parse(data: str)
            await MainActor.run {
                playlistURLs.append(url)
                playlists[url] = entries
                PlaylistCache.shared.save(entries: entries, for: url)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func loadCachedPlaylists() {
        playlists = PlaylistCache.shared.loadAll()
        playlistURLs = Array(playlists.keys)
    }

    func clearCache() {
        PlaylistCache.shared.clear()
        playlists = [:]
        playlistURLs = []
    }
}
