//
//  ForgotPasswordViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit
import ProgressHUD

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
    
    @IBAction func resetPasswordButtonDidTapped(_ sender: Any) {
        guard let email = emailTextField.text, email != "" else {
            ProgressHUD.showError(ERROR_EMPTY_EMAIL_RESET)
            return
        }
        
        Api.User.resetPassword(email: email, onSuccess: {
            self.view.endEditing(true)
            ProgressHUD.showSuccess(SUCCES_EMAIL_RESET)
            self.navigationController?.popViewController(animated: true)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
    }
    
}
