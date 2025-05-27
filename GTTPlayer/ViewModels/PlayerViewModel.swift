// ViewModel for player and Chromecast
import Foundation
import Combine
import AVKit
#if canImport(GoogleCast)
import GoogleCast
#endif
import MobileVLCKit

class PlayerViewModel: ObservableObject {
    @Published var currentEntry: M3UEntry?
    @Published var isPlaying: Bool = false
    @Published var player: AVPlayer? = nil
    @Published var errorMessage: String? = nil
    @Published var isCasting: Bool = false
    @Published var castSession: GCKSession? = nil
    @Published var volume: Float = 1.0
    @Published var playbackTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var vlcPlayer: VLCMediaPlayer? = nil

    private var timeObserver: Any?
    private var playerStatusObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?

    func play(entry: M3UEntry) {
        // Stop any local playback (but not casting)
        stop()
        print("[PlayerViewModel] play(entry:) called with entry: \(entry)")
        currentEntry = entry
        guard let url = URL(string: entry.streamURL) else {
            errorMessage = "Invalid stream URL"
            print("[PlayerViewModel] Invalid stream URL: \(entry.streamURL)")
            return
        }
        // Always use VLC for playback
        print("[PlayerViewModel] Using VLCMediaPlayer for playback")
        let media = VLCMedia(url: url)
        let vlc = VLCMediaPlayer()
        vlc.media = media
        

        // Configure VLC for AirPlay
        // These settings help ensure video is properly streamed via AirPlay
//        vlc.allowsExternalPlayback = true
//        vlc.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        // Set audio and video outputs to ensure compatibility with AirPlay
        media.addOptions([
            "network-caching": "1500"
        ])
        
        self.vlcPlayer = vlc
        vlc.play()
        isPlaying = true
        errorMessage = nil
    }

    private func observePlayerStatus(player: AVPlayer?, item: AVPlayerItem) {
        playerStatusObserver = player?.observe(\.status, options: [.new, .old], changeHandler: { [weak self] player, change in
            print("[PlayerViewModel] AVPlayer status changed: \(player.status.rawValue)")
            if player.status == .failed {
                self?.errorMessage = "Player failed: \(String(describing: player.error))"
                print("[PlayerViewModel] Player failed: \(String(describing: player.error))")
            }
        })
        playerItemStatusObserver = item.observe(\.status, options: [.new, .old], changeHandler: { [weak self] item, change in
            print("[PlayerViewModel] AVPlayerItem status changed: \(item.status.rawValue)")
            if item.status == .failed {
                self?.errorMessage = "Player item failed: \(String(describing: item.error))"
                print("[PlayerViewModel] Player item failed: \(String(describing: item.error))")
            } else if item.status == .readyToPlay {
                print("[PlayerViewModel] Player item is ready to play.")
            } else if item.status == .unknown {
                print("[PlayerViewModel] Player item status is unknown.")
            }
        })
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player = nil
        vlcPlayer?.stop()
        vlcPlayer = nil
        isPlaying = false
        playbackTime = 0.0
        duration = 0.0
    }

    func setVolume(_ value: Float) {
        player?.volume = value
        volume = value
    }

    private func observeTime() {
        guard let player = player else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.playbackTime = time.seconds
            if let duration = player.currentItem?.duration.seconds, duration > 0 {
                self?.duration = duration
            }
        }
    }

    // MARK: - Springfield Integration
    struct StreamStartResponse: Decodable {
        let uuid: String
        let pid: Int
        let originalUrl: String
        let hlsUrl: String
        let startTime: String
        let expiresAt: String
    }
    struct ActiveStream: Decodable, Identifiable {
        var id: String { hlsUrl } // Use hlsUrl as unique id
        let hlsUrl: String
        let startTime: String
        let expiresAt: String
    }
    @Published var activeStreams: [ActiveStream] = []
    @Published var isLoadingStreams: Bool = false

    func fetchActiveStreams() {
        isLoadingStreams = true
        guard let url = URL(string: "https://springfield.gaulatti.com/streams") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingStreams = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch streams: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else { return }
            do {
                let streams = try JSONDecoder().decode([ActiveStream].self, from: data)
                DispatchQueue.main.async {
                    self?.activeStreams = streams
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to decode streams."
                }
            }
        }.resume()
    }

    // Helper: Find uuid for a given hlsUrl by POSTing the original url to Springfield
    func fetchUuidForHlsUrl(hlsUrl: String, originalUrl: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://springfield.gaulatti.com/streams") else { completion(nil); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["url": originalUrl]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let result = try? JSONDecoder().decode(StreamStartResponse.self, from: data) {
                completion(result.uuid)
            } else {
                completion(nil)
            }
        }.resume()
    }

    // Stop a Springfield stream by uuid
    func stopSpringfieldStreamByUuid(uuid: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://springfield.gaulatti.com/streams/\(uuid)") else { completion?(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion?(true)
            } else {
                completion?(false)
            }
        }.resume()
    }

    // Improved stop: requires originalUrl to get uuid, then stops
    func stopSpringfieldStream(hlsUrl: String, originalUrl: String, completion: ((Bool) -> Void)? = nil) {
        fetchUuidForHlsUrl(hlsUrl: hlsUrl, originalUrl: originalUrl) { uuid in
            guard let uuid = uuid else { completion?(false); return }
            self.stopSpringfieldStreamByUuid(uuid: uuid, completion: completion)
        }
    }

    func playSpringfieldStream(hlsUrl: String) {
        // Stop any local playback (but not casting)
        stop()
        // Play the HLS stream using VLC
        guard let url = URL(string: hlsUrl) else { return }
        let media = VLCMedia(url: url)
        let vlc = VLCMediaPlayer()
        vlc.media = media
        media.addOptions([
            "network-caching": "1500"
        ])
        self.vlcPlayer = vlc
        vlc.play()
        isPlaying = true
        errorMessage = nil
    }

    // Chromecast integration (pseudo-code, requires Google Cast SDK setup)
    func castToChromecast() {
#if canImport(GoogleCast)
        print("[PlayerViewModel] castToChromecast() called")
        guard let entry = currentEntry else {
            errorMessage = "No media selected to cast."
            return
        }
        // 1. Start transcoding on Springfield
        let springfieldURL = URL(string: "https://springfield.gaulatti.com/streams")!
        var request = URLRequest(url: springfieldURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["url": entry.streamURL]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to start stream: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data,
                  let result = try? JSONDecoder().decode(StreamStartResponse.self, from: data) else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Invalid response from server."
                }
                return
            }
            // 2. Use the returned HLS URL for Chromecast
            DispatchQueue.main.async {
                self?.sendToChromecast(hlsUrl: result.hlsUrl, entry: entry)
            }
        }.resume()
#endif
    }

    // Make sendToChromecast internal so it can be called from SpringfieldStreamPlayerView
    func sendToChromecast(hlsUrl: String, entry: M3UEntry) {
        // Only stop local playback, do not stop casting
        stop()
#if canImport(GoogleCast)
        guard let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession,
              let url = URL(string: hlsUrl) else {
            errorMessage = "No Chromecast device connected or invalid HLS URL."
            return
        }
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
        mediaInfoBuilder.streamType = .live
        mediaInfoBuilder.contentType = "application/x-mpegURL"
        mediaInfoBuilder.contentID = hlsUrl
        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString(entry.name, forKey: kGCKMetadataKeyTitle)
        metadata.setString("HLS Stream", forKey: kGCKMetadataKeySubtitle)
        if let logoURL = URL(string: entry.logoURL) {
            metadata.addImage(GCKImage(url: logoURL, width: 480, height: 360))
        }
        mediaInfoBuilder.metadata = metadata
        let mediaInfo = mediaInfoBuilder.build()
        let remoteMediaClient = castSession.remoteMediaClient
        let request = GCKMediaLoadRequestDataBuilder()
        request.mediaInformation = mediaInfo
        request.autoplay = true
        remoteMediaClient?.loadMedia(with: request.build())
        isCasting = true
        self.castSession = castSession
#endif
    }

    func stopCasting() {
#if canImport(GoogleCast)
        GCKCastContext.sharedInstance().sessionManager.endSessionAndStopCasting(true)
        isCasting = false
        castSession = nil
#endif
    }
}
