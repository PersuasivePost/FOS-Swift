import UIKit

class PlaylistDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var songCountLabel: UILabel!
    
    var playlist: Playlist!
    
    private let dataManager = DataManager.shared
    private let musicPlayerManager = MusicPlayerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        title = playlist.name
        
        playlistNameLabel.text = playlist.name
        songCountLabel.text = "\(playlist.songs.count) songs"
        
        if #available(iOS 13.0, *) {
            addSongButton.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            addSongButton.setTitle("+", for: .normal)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
    }
    
    @IBAction func addSongButtonTapped(_ sender: UIButton) {
        showAddSongAlert()
    }
    
    private func showAddSongAlert() {
        let allSongs = dataManager.getAllSongs()
        let alert = UIAlertController(title: "Add Song", message: "Select a song to add", preferredStyle: .actionSheet)
        
        for song in allSongs {
            // Skip songs already in the playlist
            if playlist.songs.contains(where: { $0.id == song.id }) {
                continue
            }
            
            let action = UIAlertAction(title: "\(song.title) - \(song.artist)", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.dataManager.addSongToPlaylist(song: song, playlistId: self.playlist.id)
                // Refresh playlist data
                if let updatedPlaylist = self.dataManager.getAllPlaylists().first(where: { $0.id == self.playlist.id }) {
                    self.playlist = updatedPlaylist
                    self.songCountLabel.text = "\(self.playlist.songs.count) songs"
                    self.tableView.reloadData()
                }
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func playSong(at index: Int) {
        let selectedSong = playlist.songs[index]
        musicPlayerManager.playSong(selectedSong)
        
        // Navigate to the music player
        if let containerVC = self.navigationController?.parent as? ContainerViewController {
            containerVC.didSelectMenuItem(at: 0) // Index 0 is Home/Music Player
        }
    }
}

extension PlaylistDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let song = playlist.songs[indexPath.row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = "\(song.artist) - \(song.album)"
        cell.imageView?.image = song.albumArt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playSong(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = playlist.songs[indexPath.row]
            dataManager.removeSongFromPlaylist(songId: song.id, playlistId: playlist.id)
            
            // Refresh playlist data
            if let updatedPlaylist = dataManager.getAllPlaylists().first(where: { $0.id == playlist.id }) {
                playlist = updatedPlaylist
                songCountLabel.text = "\(playlist.songs.count) songs"
                tableView.reloadData()
            }
        }
    }
}
