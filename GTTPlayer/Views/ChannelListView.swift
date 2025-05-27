// Channel List View
import SwiftUI

struct ChannelListView: View {
    let entries: [M3UEntry]
    @State private var searchText = ""
    @State private var isGrid = false
    @State private var selectedEntry: M3UEntry? = nil

    var filteredEntries: [M3UEntry] {
        if searchText.isEmpty { return entries }
        return entries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search channels", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Button(action: { isGrid.toggle() }) {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                }
            }.padding()
            if isGrid {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: PlayerView(entry: entry)) {
                                VStack {
                                    AsyncImage(url: URL(string: entry.logoURL)) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 80, height: 80)
                                    Text(entry.name).font(.caption).lineLimit(2)
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            } else {
                List(filteredEntries) { entry in
                    NavigationLink(destination: PlayerView(entry: entry)) {
                        HStack {
                            AsyncImage(url: URL(string: entry.logoURL)) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 40, height: 40)
                            Text(entry.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Channels")
    }
}
//
//#if DEBUG
//struct ChannelListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let entries = [
//            M3UEntry(name: "Channel 1", streamURL: "http://example.com/1.m3u8", logoURL: "", group: "News"),
//            M3UEntry(name: "Channel 2", streamURL: "http://example.com/2.m3u8", logoURL: "", group: "Sports")
//        ]
//        NavigationView {
//            ChannelListView(entries: entries)
//        }
//    }
//}
//#endif
