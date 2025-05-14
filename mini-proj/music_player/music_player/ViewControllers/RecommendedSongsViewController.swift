import UIKit

class RecommendedSongsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moodSegmentedControl: UISegmentedControl!
    
    private let dataManager = DataManager.shared
    private let musicPlayerManager = MusicPlayerManager.shared
    private var recommendedSongs: [Song] = []
    private let moods = ["Happy", "Sad", "Energetic", "Relaxed", "Angry"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupMoodSelector()
        loadRecommendedSongs(for: moods[0])
    }
    
    private func setupUI() {
        title = "Recommended"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecommendedCell")
    }
    
    private func setupMoodSelector() {
        moodSegmentedControl.removeAllSegments()
        
        for (index, mood) in moods.enumerated() {
            moodSegmentedControl.insertSegment(withTitle: mood, at: index, animated: false)
        }
        
        moodSegmentedControl.selectedSegmentIndex = 0
        moodSegmentedControl.addTarget(self, action: #selector(moodChanged(_:)), for: .valueChanged)
    }
    
    private func loadRecommendedSongs(for mood: String) {
        recommendedSongs = dataManager.getRecommendedSongs(mood: mood)
        tableView.reloadData()
        
        if recommendedSongs.isEmpty {
            showNoRecommendationsMessage()
        } else {
            hideNoRecommendationsMessage()
        }
    }
    
    private func showNoRecommendationsMessage() {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        messageLabel.text = "No recommendations available for this mood"
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        
        tableView.backgroundView = messageLabel
    }
    
    private func hideNoRecommendationsMessage() {
        tableView.backgroundView = nil
    }
    
    @objc private func moodChanged(_ sender: UISegmentedControl) {
        let selectedMood = moods[sender.selectedSegmentIndex]
        loadRecommendedSongs(for: selectedMood)
    }
    
    private func playSong(at index: Int) {
        let selectedSong = recommendedSongs[index]
        musicPlayerManager.playSong(selectedSong)
        
        // Navigate to the music player
        if let containerVC = self.navigationController?.parent as? ContainerViewController {
            containerVC.didSelectMenuItem(at: 0) // Index 0 is Home/Music Player
        }
    }
}

extension RecommendedSongsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendedCell", for: indexPath)
        
        let song = recommendedSongs[indexPath.row]
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
