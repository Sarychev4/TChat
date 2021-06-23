//
//  ViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 26.04.21.
//

import UIKit

class Welcome: UIViewController {
    

    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
      
        //setupFacebookButton()
        setupSignUpButton()
        setupSignInButton()
          
    }
    
}

