import UIKit

class DownloadsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let dataManager = DataManager.shared
    private let musicPlayerManager = MusicPlayerManager.shared
    private var downloadedSongs: [Song] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadDownloadedSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDownloadedSongs()
    }
    
    private func setupUI() {
        title = "Downloads"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DownloadCell")
    }
    
    private func loadDownloadedSongs() {
        downloadedSongs = dataManager.getDownloadedSongs()
        
        if downloadedSongs.isEmpty {
            showEmptyStateMessage()
        } else {
            hideEmptyStateMessage()
        }
        
        tableView.reloadData()
    }
    
    private func showEmptyStateMessage() {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        messageLabel.text = "No downloaded songs yet.\nGo to All Songs and download some music."
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        
        tableView.backgroundView = messageLabel
    }
    
    private func hideEmptyStateMessage() {
        tableView.backgroundView = nil
    }
    
    private func playSong(at index: Int) {
        // Set the queue and play the selected song
        musicPlayerManager.setQueue(songs: downloadedSongs, startIndex: index)
        
        // Navigate to the music player
        if let containerVC = self.navigationController?.parent as? ContainerViewController {
            containerVC.didSelectMenuItem(at: 0) // Index 0 is Home/Music Player
        }
    }
    
    private func showClassifyAlert(for song: Song) {
        let alert = UIAlertController(title: "Classify Song", message: "Select a mood for \(song.title)", preferredStyle: .actionSheet)
        
        let moods = ["Happy", "Sad", "Energetic", "Relaxed", "Angry"]
        
        for mood in moods {
            let action = UIAlertAction(title: mood, style: .default) { [weak self] _ in
                self?.dataManager.updateSongMoodTag(songId: song.id, moodTag: mood)
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath)
        
        let song = downloadedSongs[indexPath.row]
        cell.textLabel?.text = song.title
        
        var detailText = "\(song.artist) - \(song.album)"
        if let mood = song.moodTag {
            detailText += " • \(mood)"
        }
        cell.detailTextLabel?.text = detailText
        
        cell.imageView?.image = song.albumArt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playSong(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let song = downloadedSongs[indexPath.row]
        
        let classifyAction = UIContextualAction(style: .normal, title: "Classify") { [weak self] (_, _, completionHandler) in
            self?.showClassifyAlert(for: song)
            completionHandler(true)
        }
        classifyAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.dataManager.removeSongFromDownloads(songId: song.id)
            self?.loadDownloadedSongs()
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, classifyAction])
    }
}

