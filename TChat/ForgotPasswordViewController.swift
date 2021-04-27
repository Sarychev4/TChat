//
//  ForgotPasswordViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        
        setupEmailTextField()
        setupResetButton()

    }

    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
