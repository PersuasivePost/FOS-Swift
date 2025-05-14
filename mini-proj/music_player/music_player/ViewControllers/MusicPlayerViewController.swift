
import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private let musicPlayerManager = MusicPlayerManager.shared
    private let dataManager = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMusicPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update UI with current song
        if let currentSong = musicPlayerManager.currentSong {
            updateUI(with: currentSong)
            updatePlayPauseButton(isPlaying: musicPlayerManager.isPlaying)
        } else {
            // No song is playing, load initial song if available
            loadInitialSong()
        }
    }
    
    private func setupUI() {
        title = "Now Playing"
        
        albumArtImageView.layer.cornerRadius = 8
        albumArtImageView.clipsToBounds = true
        
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        if #available(iOS 13.0, *) {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            previousButton.setImage(UIImage(systemName: "backward.fill"), for: .normal)
            nextButton.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        }
    }
    
    private func setupMusicPlayer() {
        musicPlayerManager.onPlaybackTimeChanged = { [weak self] currentTime, duration in
            self?.updatePlaybackTime(currentTime: currentTime, duration: duration)
        }
        
        musicPlayerManager.onSongChanged = { [weak self] song in
            self?.updateUI(with: song)
        }
        
        musicPlayerManager.onPlaybackStateChanged = { [weak self] isPlaying in
            self?.updatePlayPauseButton(isPlaying: isPlaying)
        }
    }
    
    private func loadInitialSong() {
        let allSongs = dataManager.getAllSongs()
        if let firstSong = allSongs.first {
            musicPlayerManager.setQueue(songs: allSongs, startIndex: 0)
        }
    }
    
    private func updateUI(with song: Song) {
        titleLabel.text = song.title
        artistLabel.text = song.artist
        albumArtImageView.image = song.albumArt
        
        updatePlaybackTime(currentTime: musicPlayerManager.getCurrentTime(), duration: song.duration)
    }
    
    private func updatePlaybackTime(currentTime: TimeInterval, duration: TimeInterval) {
        // Update slider
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = Float(currentTime)
        
        // Update time labels
        timeElapsedLabel.text = formatTime(currentTime)
        timeRemainingLabel.text = "-\(formatTime(duration - currentTime))"
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func updatePlayPauseButton(isPlaying: Bool) {
        if #available(iOS 13.0, *) {
            let imageName = isPlaying ? "pause.fill" : "play.fill"
            playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        } else {
            playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        musicPlayerManager.togglePlayPause()
    }
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        musicPlayerManager.playPrevious()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        musicPlayerManager.playNext()
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        timeElapsedLabel.text = formatTime(TimeInterval(sender.value))
        let remainingTime = TimeInterval(progressSlider.maximumValue) - TimeInterval(sender.value)
        timeRemainingLabel.text = "-\(formatTime(remainingTime))"
    }
    
    @objc func sliderTouchUp(_ sender: UISlider) {
        musicPlayerManager.seek(to: TimeInterval(sender.value))
    }
}
