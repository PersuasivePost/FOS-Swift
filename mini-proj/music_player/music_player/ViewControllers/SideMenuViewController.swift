import UIKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SideMenuDelegate?
    
    private let menuItems = ["Home", "All Songs", "Albums", "Playlists", "Downloads", "Recommended"]
    private let menuIcons = ["house", "music.note.list", "rectangle.stack", "music.note", "arrow.down.circle", "star"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        // Set title for the menu
        title = "Music Player"
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        if #available(iOS 13.0, *) {
            cell.imageView?.image = UIImage(systemName: menuIcons[indexPath.row])
        }
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectMenuItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
