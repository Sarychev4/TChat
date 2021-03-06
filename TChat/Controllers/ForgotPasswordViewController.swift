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
    @IBOutlet weak var backToSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        setupEmailTextField()
        setupResetButton()
        setupBackToSignInButton()
    }

    @IBAction func backToSignInClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetPasswordButtonDidTapped(_ sender: Any) {
        guard let email = emailTextField.text, email != "" else {
            let alert = UIAlertController(title: "Empty e-mail", message: ERROR_EMPTY_EMAIL_RESET, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Api.User.resetPassword(email: email, onSuccess: {
            self.view.endEditing(true)
            let alert = UIAlertController(title: "E-mail reset", message: SUCCES_EMAIL_RESET, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }) { (errorMessage) in
            let alert = UIAlertController(title: "E-mail reset", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
