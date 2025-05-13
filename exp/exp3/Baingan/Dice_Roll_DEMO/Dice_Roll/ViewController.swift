import UIKit

class ViewController: UIViewController {
    
    var colorSwitch: UISwitch!
    let colors: [UIColor] = [.purple, .blue, .green, .yellow, .orange, .red]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Initialize the colorSwitch
        colorSwitch = UISwitch()
        
        // Set the frame of the colorSwitch
        colorSwitch.frame = CGRect(x: self.view.frame.size.width / 2 - 30, y: self.view.frame.size.height / 2, width: 0, height: 0)
        
        // Add the target-action for value change of the switch
        colorSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        // Add the switch to the view
        self.view.addSubview(colorSwitch)
        
        // Set initial background color
        self.view.backgroundColor = .white
    }
    
    // Action method when switch value changes
    @IBAction func Baingan(_ sender: Any) {
        if colorSwitch.isOn {
            self.view.backgroundColor = .black
        }
        else {
            self.view.backgroundColor = .white
        }
    }
    
    @objc func switchChanged() {
        if colorSwitch.isOn {
            // Change the background color to a random one when the switch is on
            let randomIndex = Int.random(in: 0..<colors.count)
            self.view.backgroundColor = colors[randomIndex]
        } else {
            // Reset the background color when the switch is off
            self.view.backgroundColor = .white
        }
    }
}
