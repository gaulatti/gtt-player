//
//  GTTPlayerApp.swift
//  GTTPlayer
//
//  Created by Javier Godoy Núñez on 5/27/25.
//

import SwiftUI

struct SpringfieldStreamsView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @State private var selectedStream: PlayerViewModel.ActiveStream?
    @State private var stopResult: String?
    @State private var isStopping: String? = nil // uuid of stream being stopped

    var body: some View {
        NavigationView {
            List(viewModel.activeStreams) { stream in
                NavigationLink(destination: SpringfieldStreamPlayerView(hlsUrl: stream.hlsUrl)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(stream.hlsUrl).font(.caption).lineLimit(1)
                        Text("Started: \(stream.startTime)").font(.footnote)
                        Text("Expires: \(stream.expiresAt)").font(.footnote)
                        HStack(spacing: 16) {
                            Button(action: {
                                let uuid = uuidFromHlsUrl(stream.hlsUrl) ?? stream.id
                                isStopping = stream.id
                                viewModel.stopSpringfieldStreamByUuid(uuid: uuid) { success in
                                    DispatchQueue.main.async {
                                        stopResult = success ? "Stopped successfully" : "Failed to stop stream"
                                        isStopping = nil
                                        viewModel.fetchActiveStreams()
                                    }
                                }
                            }) {
                                if isStopping == stream.id {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Stop", systemImage: "stop.fill")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Springfield Streams")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.fetchActiveStreams() }) {
                        Label("Refresh Streams", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    CastButton()
                        .frame(width: 32, height: 32)
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoadingStreams {
                        ProgressView("Loading Streams...")
                    }
                }, alignment: .center
            )
            if let stopResult = stopResult {
                Text(stopResult).foregroundColor(.red)
            }
        }
        .onAppear { viewModel.fetchActiveStreams() }
    }
}

// Helper to extract uuid from .m3u8 url
func uuidFromHlsUrl(_ hlsUrl: String) -> String? {
    // Example: .../3684f04d-63fd-4af5-8432-cdc6cb3bf1b8.m3u8
    guard let url = URL(string: hlsUrl) else { return nil }
    let last = url.lastPathComponent
    if last.hasSuffix(".m3u8") {
        return String(last.dropLast(5)) // remove .m3u8
    }
    return nil
}

struct SpringfieldStreamPlayerView: View {
    let hlsUrl: String
    @StateObject private var viewModel = PlayerViewModel()
    @State private var hasStarted = false
    
    var body: some View {
        VStack {
            Text("Playing Springfield Stream")
            Button(action: {
                viewModel.playSpringfieldStream(hlsUrl: hlsUrl)
                hasStarted = true
            }) {
                Label("Play", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            Button(action: {
                viewModel.sendToChromecast(hlsUrl: hlsUrl, entry: M3UEntry(name: "Springfield Stream", logoURL: "", group: "", streamURL: hlsUrl))
            }) {
                Label("Cast to Chromecast", systemImage: "airplayvideo")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.top)
            if hasStarted, let vlcPlayer = viewModel.vlcPlayer {
                VLCPlayerView(vlcPlayer: vlcPlayer)
                    .frame(height: 220)
            } else {
                Text("Press Play to start playback.")
                    .foregroundColor(.secondary)
                    .padding()
            }
            Button(action: {
                viewModel.stop()
                hasStarted = false
            }) {
                Label("Stop", systemImage: "stop.fill")
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.top)
            Spacer()
        }
        .onAppear {
            hasStarted = false
        }
        .padding()
    }
}

#if DEBUG
struct SpringfieldStreamsView_Previews: PreviewProvider {
    static var previews: some View {
        SpringfieldStreamsView()
    }
}
#endif
