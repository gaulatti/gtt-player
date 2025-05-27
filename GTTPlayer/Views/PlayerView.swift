// Player View
import SwiftUI
import _AVKit_SwiftUI
import MobileVLCKit
import GoogleCast
import AVKit

struct PlayerView: View {
    let entry: M3UEntry
    @StateObject private var viewModel = PlayerViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(entry.name).font(.headline).padding(.top)
            AsyncImage(url: URL(string: entry.logoURL)) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            .frame(width: 120, height: 120)
            if !viewModel.isCasting {
                if let vlcPlayer = viewModel.vlcPlayer {
                    VLCPlayerView(vlcPlayer: vlcPlayer)
                        .frame(height: 220)
                } else {
                    VideoPlayer(player: viewModel.player)
                        .frame(height: 220)
                }
            } else {
                Text("Casting to Chromecast...").foregroundColor(.blue)
            }
            HStack(spacing: 24) {
                Button(action: { viewModel.play(entry: entry) }) {
                    Image(systemName: "play.fill")
                }
                Button(action: { viewModel.pause() }) {
                    Image(systemName: "pause.fill")
                }
                Button(action: { viewModel.stop() }) {
                    Image(systemName: "stop.fill")
                }
                Slider(value: Binding(get: { viewModel.volume }, set: { viewModel.setVolume($0) }), in: 0...1)
                    .frame(width: 100)
                CastButton()
                    .frame(width: 44, height: 44)
                AirPlayButton()
                    .frame(width: 44, height: 44)
            }
            HStack {
                Text(timeString(viewModel.playbackTime))
                Slider(value: Binding(get: { viewModel.playbackTime }, set: { newValue in
                    if let player = viewModel.player {
                        let cmTime = CMTime(seconds: newValue, preferredTimescale: 1)
                        player.seek(to: cmTime)
                    }
                }), in: 0...(viewModel.duration > 0 ? viewModel.duration : 1))
                Text(timeString(viewModel.duration))
            }.padding(.horizontal)
            Button(action: { viewModel.castToChromecast() }) {
                HStack {
                    Image(systemName: "airplayvideo")
                    Text("Cast to Chromecast")
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .disabled(viewModel.isCasting)
            if viewModel.isCasting {
                Button("Stop Casting") { viewModel.stopCasting() }
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
            Spacer()
        }
        .onAppear { viewModel.play(entry: entry) }
        .navigationTitle("Player")
    }

    private func timeString(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let min = intSec / 60
        let sec = intSec % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

struct VLCPlayerView: UIViewRepresentable {
    let vlcPlayer: VLCMediaPlayer
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        vlcPlayer.drawable = view
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        vlcPlayer.drawable = uiView
    }
}

struct CastButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GCKUICastButton {
        let button = GCKUICastButton(frame: .zero)
        button.tintColor = UIColor.systemBlue
        return button
    }
    func updateUIView(_ uiView: GCKUICastButton, context: Context) {}
}

// AirPlay button for SwiftUI
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePicker = AVRoutePickerView()
        routePicker.tintColor = .systemBlue
        routePicker.activeTintColor = .systemBlue
        return routePicker
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

//#if DEBUG
//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        let entry = M3UEntry(name: "Preview Channel", streamURL: "http://example.com/preview.m3u8", logoURL: "", group: "Preview")
//        NavigationView {
//            PlayerView(entry: entry)
//        }
//    }
//}
//#endif
