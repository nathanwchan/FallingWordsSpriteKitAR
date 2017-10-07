//
//  HomeViewController.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/7/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var wordProviderType: String = "simple"

    @IBAction func transportationButtonClick(_ sender: Any) {
        wordProviderType = "transportation"
        segueToARVC()
    }
    @IBAction func chineseButtonClick(_ sender: Any) {
        wordProviderType = "chinese"
        segueToARVC()
    }
    
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

        // Do any additional setup after loading the view.
    }
}
