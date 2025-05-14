import UIKit

class PlaylistsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private let dataManager = DataManager.shared
    private var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadPlaylists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlaylists()
    }
    
    private func setupUI() {
        title = "Playlists"
        
        if #available(iOS 13.0, *) {
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            addButton.setTitle("+", for: .normal)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaylistCell")
    }
    
    private func loadPlaylists() {
        playlists = dataManager.getAllPlaylists()
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        showCreatePlaylistAlert()
    }
    
    private func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter a name for your playlist", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Playlist Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self, let textField = alert.textFields?.first, let name = textField.text, !name.isEmpty else { return }
            
            let _ = self.dataManager.createPlaylist(name: name)
            self.loadPlaylists()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        present(alert, animated: true)
    }
    
    private func showPlaylist(_ playlist: Playlist) {
        let playlistDetailVC = PlaylistDetailViewController()
        playlistDetailVC.playlist = playlist
        navigationController?.pushViewController(playlistDetailVC, animated: true)
    }
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text = playlist.name
        cell.detailTextLabel?.text = "\(playlist.songs.count) songs"
        
        if #available(iOS 13.0, *) {
            cell.imageView?.image = UIImage(systemName: "music.note.list")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        showPlaylist(playlist)
    }
}
