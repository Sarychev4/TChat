//
//  SignUpViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 26.04.21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        
        setupTitleLabel()
        setupAvatar()
        setupFullNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
        
    }
    
//    @IBAction func dissmissAction(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
    
    
    
    //MARK: - Auth with FireBase
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        
        //Dismiss keyboard when user touch view
        self.view.endEditing(true)
        
        self.validateFields()
        self.signUp(onSuccess: {
            Api.User.isOnline(bool: true)
            //switch view
            //(UIApplication.shared.delegate as! SceneDelegate).configureInitialViewController()
             (UIApplication.shared.connectedScenes
                 .first!.delegate as! SceneDelegate).configureInitialViewController()
        }) {
            (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}
