import UIKit
import MobileCoreServices

class AllSongsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let dataManager = DataManager.shared
    private let musicPlayerManager = MusicPlayerManager.shared
    
    private var allSongs: [Song] = []
    private var filteredSongs: [Song] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchBar()
        loadSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSongs() // Refresh songs when view appears
    }
    
    private func setupUI() {
        title = "All Songs"
        
        // Add import button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(importButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search songs, artists, albums..."
    }
    
    private func loadSongs() {
        allSongs = dataManager.getAllSongs()
        
        if isSearching {
            filteredSongs = dataManager.searchSongs(query: searchBar.text ?? "")
        } else {
            filteredSongs = allSongs
        }
        
        tableView.reloadData()
    }
    
    private func playSong(at index: Int) {
        let songs = isSearching ? filteredSongs : allSongs
        let selectedSong = songs[index]
        
        // Set the queue and play the selected song
        musicPlayerManager.setQueue(songs: songs, startIndex: index)
        
        // Navigate to the music player
        if let containerVC = self.navigationController?.parent as? ContainerViewController {
            containerVC.didSelectMenuItem(at: 0) // Index 0 is Home/Music Player
        }
    }
    
    @objc private func importButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AllSongsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredSongs.count : allSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let song = isSearching ? filteredSongs[indexPath.row] : allSongs[indexPath.row]
        
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = "\(song.artist) - \(song.album)"
        cell.imageView?.image = song.albumArt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playSong(at: indexPath.row)
    }
}

// MARK: - UISearchBarDelegate

extension AllSongsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredSongs = allSongs
        } else {
            isSearching = true
            filteredSongs = dataManager.searchSongs(query: searchText)
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredSongs = allSongs
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

// MARK: - UIDocumentPickerDelegate

extension AllSongsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Importing", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        let group = DispatchGroup()
        var importedCount = 0
        
        for url in urls {
            group.enter()
            
            // Start accessing the security-scoped resource
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            
            dataManager.importSong(from: url) { song in
                if song != nil {
                    importedCount += 1
                }
                
                // Stop accessing the security-scoped resource
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            // Dismiss loading alert
            loadingAlert.dismiss(animated: true) {
                // Show success message
                let message = importedCount > 0 ? "Successfully imported \(importedCount) songs." : "No songs were imported."
                let alert = UIAlertController(title: "Import Complete", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                
                // Reload songs
                self?.loadSongs()
            }
        }
    }
}
