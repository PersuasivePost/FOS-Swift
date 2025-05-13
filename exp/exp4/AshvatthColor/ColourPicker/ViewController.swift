//
//  ViewController.swift
//  ColourPicker
//
//  Created by KJSCE on 18/02/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    @IBOutlet weak var LockButton: UIButton!
        

    @IBOutlet weak var colourView: UIView!

    @IBOutlet weak var rgbValueLabel: UILabel!
    
    var isLocked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        redSlider.value = 0.5
        greenSlider.value = 0.5
        blueSlider.value = 0.5

        redSwitch.isOn = true
        greenSwitch.isOn = true
        blueSwitch.isOn = true
    }
    
    @IBAction func redSwitch(_ sender: UISwitch) {
        updateColor()
    }
    @IBAction func greenSwitch(_ sender: UISwitch) {
        updateColor()
    }
    @IBAction func blueSwitch(_ sender: UISwitch) {
        updateColor()
    }
    @IBAction func redSlider(_ sender: UISlider) {
        updateColor()
    }
    @IBAction func greenSlider(_ sender: UISlider) {
        updateColor()
    }
    @IBAction func blueSlider(_ sender: UISlider) {
        updateColor()
    }
    
    
    @IBAction func LockButton(_ sender: UIButton) {
        isLocked.toggle()
        sender.setTitle(isLocked ? "Unlock" : "Lock", for: .normal)
//        updateColor()
    }
    func updateColor() {
        if isLocked{
            return
        }

            var red: CGFloat = CGFloat(redSlider.value)
            var green:CGFloat = CGFloat(greenSlider.value)
            var blue:CGFloat = CGFloat(blueSlider.value)

            if !redSwitch.isOn {
                red = 0.0
            }
            if !greenSwitch.isOn {
                green = 0.0
            }
            if !blueSwitch.isOn {
                blue = 0.0
            }

            colourView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

            
            rgbValueLabel.text = String(format: "RGB: (%.0f, %.0f, %.0f)", red * 255, green * 255, blue * 255)

        }
}

