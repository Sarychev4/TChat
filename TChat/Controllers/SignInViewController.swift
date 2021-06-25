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
   // @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        
        setupTitleLabel()
        setupEmailTextField()
        setupPasswordTextField()
       // setupSignUpButton()
        setupSignInButton()
        setupForgotPasswordButton()
    }

//    @IBAction func dismissAction(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
    
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        //Dismiss keyboard when user touch view
        self.view.endEditing(true)
        
        self.validateFields()
        self.signIn(onSuccess: {
            Api.User.isOnline(bool: true)
            //switch view
           //(UIApplication.shared.delegate as! SceneDelegate).configureInitialViewController()
            (UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate).configureInitialViewController()
        }) { (errorMessage) in
            //ProgressHUD.showError(errorMessage)
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}
