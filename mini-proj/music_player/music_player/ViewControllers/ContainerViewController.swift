import UIKit

class ContainerViewController: UIViewController {
    
    private enum MenuState {
        case opened
        case closed
    }
    private var menuState: MenuState = .closed

    private var menuVC: SideMenuViewController!
    private var homeVC: MusicPlayerViewController!
    private var allSongsVC: AllSongsViewController!
    private var albumsVC: AlbumsViewController!
    private var playlistsVC: PlaylistsViewController!
    private var downloadsVC: DownloadsViewController!
    private var recommendedVC: RecommendedSongsViewController!

    
    private var navVC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildVCs()
    }
    
    private func addChildVCs() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

            menuVC = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
            homeVC = mainStoryboard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController
            allSongsVC = mainStoryboard.instantiateViewController(withIdentifier: "AllSongsViewController") as? AllSongsViewController
            albumsVC = mainStoryboard.instantiateViewController(withIdentifier: "AlbumsViewController") as? AlbumsViewController
            playlistsVC = mainStoryboard.instantiateViewController(withIdentifier: "PlaylistsViewController") as? PlaylistsViewController
            downloadsVC = mainStoryboard.instantiateViewController(withIdentifier: "DownloadsViewController") as? DownloadsViewController
            recommendedVC = mainStoryboard.instantiateViewController(withIdentifier: "RecommendedSongsViewController") as? RecommendedSongsViewController
        // Menu Controller
        menuVC.delegate = self
        addChild(menuVC)
        view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        
        // Home Controller (Music Player)
        let navVC = UINavigationController(rootViewController: homeVC)
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        self.navVC = navVC
        
        // Add menu button to navigation bar
        homeVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(didTapMenuButton)
        )
    }
    
    @objc private func didTapMenuButton() {
        toggleMenu()
    }
    
    private func toggleMenu() {
        switch menuState {
        case .closed:
            // Open menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = self.view.bounds.width / 1.5
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .opened
                }
            }
            
        case .opened:
            // Close menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = 0
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .closed
                }
            }
        }
    }
    
    private func updateRootVC(_ viewController: UIViewController) {
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(didTapMenuButton)
        )
        
        navVC?.setViewControllers([viewController], animated: false)
        
        if menuState == .opened {
            toggleMenu()
        }
    }
}

extension ContainerViewController: SideMenuDelegate {
    func didSelectMenuItem(at index: Int) {
        switch index {
        case 0:
            updateRootVC(homeVC)
        case 1:
            updateRootVC(allSongsVC)
        case 2:
            updateRootVC(albumsVC)
        case 3:
            updateRootVC(playlistsVC)
        case 4:
            updateRootVC(downloadsVC)
        case 5:
            updateRootVC(recommendedVC)
        default:
            break
        }
    }
}

