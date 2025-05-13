
//  ViewController.swift
//  Dice_Roll
//
//  Created by KJSCE on 11/02/25.
//

import UIKit

class ViewController: UIViewController {
    
    // IBOutlet for the UIImageView where the dice face will appear
    @IBOutlet weak var diceImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let diceImages: [UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!,
        UIImage(named: "6")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diceImageView.image = diceImages[0]
    }
    
    
    
    @IBAction func rollDice(_ sender: UIButton) {
        // Generate a random index between 0 and 5
        let randomIndex = Int.random(in: 0..<diceImages.count)
        
        // Set the new dice image from the array
        diceImageView.image = diceImages[randomIndex]
        
        resultLabel.text = "You rolled: \(randomIndex + 1)"  // Update label
    }
}

