import UIKit

class AlbumSongsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var songCountLabel: UILabel!
    
    var album: String = ""
    var songs: [Song] = []
    
    private let musicPlayerManager = MusicPlayerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        title = album
        
        if let firstSong = songs.first {
            albumArtImageView.image = firstSong.albumArt
            albumArtImageView.layer.cornerRadius = 8
            albumArtImageView.clipsToBounds = true
        }
        
        albumTitleLabel.text = album
        songCountLabel.text = "\(songs.count) songs"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
    }
    
    private func playSong(at index: Int) {
        let selectedSong = songs[index]
        musicPlayerManager.playSong(selectedSong)
        
        // Navigate to the music player
        if let containerVC = self.navigationController?.parent as? ContainerViewController {
            containerVC.didSelectMenuItem(at: 0) // Index 0 is Home/Music Player
        }
    }
}

extension AlbumSongsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let song = songs[indexPath.row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playSong(at: indexPath.row)
    }
}
