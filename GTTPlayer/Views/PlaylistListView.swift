// Playlist List View
import SwiftUI
import Combine

struct PlaylistListView: View {
    @StateObject private var viewModel = PlaylistViewModel()
    @State private var newURL: String = ""
    @State private var showAlert = false
    @State private var selectedPlaylist: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter playlist URL", text: $newURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Add") {
                        Task {
                            await viewModel.addPlaylist(url: newURL)
                            newURL = ""
                        }
                    }.disabled(newURL.isEmpty)
                }.padding()
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                List {
                    ForEach(viewModel.playlistURLs, id: \.self) { url in
                        NavigationLink(destination: GroupListView(entries: viewModel.playlists[url] ?? [])) {
                            Text(url)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let url = viewModel.playlistURLs[index]
                            viewModel.playlists[url] = nil
                        }
                        viewModel.playlistURLs.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
                Button("Clear Cache") {
                    viewModel.clearCache()
                }.padding()
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CastButton()
                        .frame(width: 32, height: 32)
                }
            }
            .alert(isPresented: Binding<Bool>(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
            .onAppear { viewModel.loadCachedPlaylists() }
        }
    }
}

#if DEBUG
struct PlaylistListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaylistListView()
        }
    }
}
#endif
