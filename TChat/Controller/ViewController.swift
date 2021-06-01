//
//  ViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 26.04.21.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
      
        setupFacebookButton()
        setupCreateAccountButton()
          
    }
    
}

