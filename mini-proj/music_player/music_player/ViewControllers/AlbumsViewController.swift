import UIKit

class AlbumsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let dataManager = DataManager.shared
    private var albums: [String] = []
    private var albumSongs: [String: [Song]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        loadAlbums()
    }
    
    private func setupUI() {
        title = "Albums"
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "AlbumCell")
        
        // Setup layout
        let layout = UICollectionViewFlowLayout()
        let width = (view.frame.width - 40) / 2 // 2 columns with padding
        layout.itemSize = CGSize(width: width, height: width + 40) // Height for image + label
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }
    
    private func loadAlbums() {
        albums = dataManager.getAlbums()
        albumSongs = dataManager.getSongsByAlbum()
        collectionView.reloadData()
    }
    
    // MARK: - Navigation
    
    private func showSongsForAlbum(_ album: String) {
        guard let songsVC = storyboard?.instantiateViewController(withIdentifier: "AlbumSongsViewController") as? AlbumSongsViewController else {
            return
        }
        
        songsVC.album = album
        songsVC.songs = albumSongs[album] ?? []
        navigationController?.pushViewController(songsVC, animated: true)
    }

}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath)
        
        // Configure cell
        let album = albums[indexPath.item]
        
        // Find first song of this album to get album art
        if let firstSong = albumSongs[album]?.first {
            // Create image view for album art
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.width))
            imageView.image = firstSong.albumArt
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            // Create label for album name
            let label = UILabel(frame: CGRect(x: 0, y: cell.frame.width + 5, width: cell.frame.width, height: 30))
            label.text = album
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            // Add subviews
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.contentView.addSubview(imageView)
            cell.contentView.addSubview(label)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.item]
        showSongsForAlbum(album)
    }
}
