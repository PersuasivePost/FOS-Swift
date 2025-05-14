import Foundation
import AVFoundation
import MediaPlayer

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    
    private var audioPlayer: AVAudioPlayer?
    private(set) var currentSong: Song?
    private(set) var isPlaying = false
    private var timer: Timer?
    
    // Callback for updating UI
    var onPlaybackTimeChanged: ((TimeInterval, TimeInterval) -> Void)?
    var onSongChanged: ((Song) -> Void)?
    var onPlaybackStateChanged: ((Bool) -> Void)?
    var onPlaybackFinished: (() -> Void)?
    
    // Queue management
    private var queue: [Song] = []
    private var currentIndex: Int = 0
    
    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            
            if let _ = self.audioPlayer, !self.isPlaying {
                self.togglePlayPause()
                return .success
            }
            return .commandFailed
        }
        
        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            
            if let _ = self.audioPlayer, self.isPlaying {
                self.togglePlayPause()
                return .success
            }
            return .commandFailed
        }
        
        // Next track command
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            
            self.playNext()
            return .success
        }
        
        // Previous track command
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            
            self.playPrevious()
            return .success
        }
    }
    
    // MARK: - Playback Control
    
    func playSong(_ song: Song) {
        do {
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOf: song.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Update state
            currentSong = song
            isPlaying = true
            
            // Start timer for UI updates
            startTimer()
            
            // Update now playing info
            updateNowPlayingInfo()
            
            // Notify listeners
            onSongChanged?(song)
            onPlaybackStateChanged?(true)
        } catch {
            print("Failed to play song: \(error)")
        }
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer, let song = currentSong else { return }
        
        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        
        isPlaying = !isPlaying
        updateNowPlayingInfo()
        onPlaybackStateChanged?(isPlaying)
    }
    
    func playNext() {
        if queue.isEmpty || currentIndex >= queue.count - 1 {
            // End of queue
            return
        }
        
        currentIndex += 1
        playSong(queue[currentIndex])
    }
    
    func playPrevious() {
        if queue.isEmpty || currentIndex <= 0 {
            // Start of queue
            return
        }
        
        currentIndex -= 1
        playSong(queue[currentIndex])
    }
    
    // MARK: - Queue Management
    
    func setQueue(songs: [Song], startIndex: Int = 0) {
        queue = songs
        currentIndex = startIndex
        
        if !queue.isEmpty && currentIndex < queue.count {
            playSong(queue[currentIndex])
        }
    }
    
    func getCurrentQueue() -> [Song] {
        return queue
    }
    
    func addToQueue(song: Song) {
        queue.append(song)
    }
    
    func clearQueue() {
        queue.removeAll()
        currentIndex = 0
    }
    
    // MARK: - Playback Info
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.onPlaybackTimeChanged?(player.currentTime, player.duration)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    func getDuration() -> TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    // MARK: - Now Playing Info
    
    private func updateNowPlayingInfo() {
        guard let song = currentSong, let player = audioPlayer else { return }
        
        var nowPlayingInfo = [String: Any]()
        
        // Set song metadata
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = song.album
        
        // Set playback info
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Set artwork
        if let artwork = song.albumArt {
            let albumArt = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArt
        }
        
        // Update the now playing info center
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // Auto-play next song if available
            if currentIndex < queue.count - 1 {
                playNext()
            } else {
                // End of queue
                isPlaying = false
                onPlaybackStateChanged?(false)
                onPlaybackFinished?()
            }
        }
    }
}
