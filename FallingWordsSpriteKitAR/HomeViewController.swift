//
//  HomeViewController.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/7/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    var wordProviderType: String = "simple"
    
    func segueToARVC() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ARSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ARSegue":
            guard let viewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            viewController.wordProviderType = wordProviderType
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.alignment = .fill
        buttonsStackView.spacing = 20
        
        for i in 1...5 {
            let gradeButton = UIButton(frame: .zero)
            gradeButton.tag = i
            gradeButton.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: .touchUpInside)
            gradeButton.setTitle("Grade \(i)", for: .normal)
            gradeButton.setTitleColor(UIColor(red: 0.06, green: 0.29, blue: 0.56, alpha: 1.0), for: .normal)
            gradeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
            gradeButton.backgroundColor = .white
            gradeButton.layer.cornerRadius = 20
            gradeButton.heightAnchor.constraint(equalToConstant: 50)
            
            buttonsStackView.addArrangedSubview(gradeButton)
        }
    }
    
    @objc func buttonClicked(sender: UIButton) {
        self.wordProviderType = "grade\(sender.tag)"
        segueToARVC()
    }
}
