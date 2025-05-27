// Group List View
import SwiftUI

struct GroupListView: View {
    let entries: [M3UEntry]
    @State private var searchText = ""
    @State private var selectedGroup: String? = nil

    var groups: [String] {
        let allGroups = Set(entries.map { $0.group })
        return ["All Items"] + allGroups.sorted()
    }

    var filteredGroups: [String] {
        if searchText.isEmpty { return groups }
        return groups.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack {
            TextField("Search groups", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(filteredGroups, id: \.self) { group in
                NavigationLink(destination: ChannelListView(entries: group == "All Items" ? entries : entries.filter { $0.group == group })) {
                    Text(group)
                }
            }
        }
        .navigationTitle("Groups")
    }
}

//#if DEBUG
//struct GroupListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let entries = [
//            M3UEntry(name: "Channel 1", streamURL: "http://example.com/1.m3u8", logoURL: "", group: "News"),
//            M3UEntry(name: "Channel 2", streamURL: "http://example.com/2.m3u8", logoURL: "", group: "Sports")
//        ]
//        NavigationView {
//            GroupListView(entries: entries)
//        }
//    }
//}
//#endif
