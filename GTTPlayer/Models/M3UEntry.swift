// Model for a single M3U channel entry
import Foundation

struct M3UEntry: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let logoURL: String
    let group: String
    let streamURL: String

    private enum CodingKeys: String, CodingKey {
        case name, logoURL, group, streamURL
    }
}
