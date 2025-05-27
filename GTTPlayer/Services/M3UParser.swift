// Service to parse M3U playlists
import Foundation

class M3UParser {
    static func parse(data: String) -> [M3UEntry] {
        var entries: [M3UEntry] = []
        let lines = data.components(separatedBy: .newlines)
        var currentName = ""
        var currentLogo = ""
        var currentGroup = ""
        for i in 0..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("#EXTINF:") {
                // Extract attributes
                let pattern = #"tvg-name=\"([^\"]*)\".*?tvg-logo=\"([^\"]*)\".*?group-title=\"([^\"]*)\".*?,(.*)"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                    func group(_ idx: Int) -> String {
                        let range = match.range(at: idx)
                        if let swiftRange = Range(range, in: line) {
                            return String(line[swiftRange])
                        }
                        return ""
                    }
                    currentName = group(1)
                    currentLogo = group(2)
                    currentGroup = group(3)
                }
            } else if line.hasPrefix("http") {
                // Stream URL line
                let entry = M3UEntry(
                    name: currentName,
                    logoURL: currentLogo,
                    group: currentGroup,
                    streamURL: line
                )
                entries.append(entry)
            }
        }
        return entries
    }
}
