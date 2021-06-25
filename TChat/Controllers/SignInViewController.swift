//
//  SignInViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        setupEmailTextField()
        setupPasswordTextField()
        setupSignInButton()
        setupForgotPasswordButton()
    }
    
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        //Dismiss keyboard when user touch view
        self.view.endEditing(true)
        self.validateFields()
        
        self.signIn(onSuccess: {
            Api.User.isOnline(bool: true)
            (UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate).configureInitialViewController()
        }) { (errorMessage) in
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
