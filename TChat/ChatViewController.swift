//
//  ChatViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 30.04.21.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePartner: UIImage! // image from users VC
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var placeholderLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInputContainer()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView() //Clear separate borders of messages??? //FOOTER VIEW FOR ALL TABLE
    }
    
    func setupInputContainer(){
        let mediaImg = UIImage(named: "attachment_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mediaButton.setImage(mediaImg, for: .normal)
        mediaButton.tintColor = .lightGray
        
        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        audioButton.setImage(micImg, for: .normal)
        audioButton.tintColor = .lightGray
        
        setupInputTextView()
    }
    
    func setupInputTextView(){
        
        inputTextView.delegate = self
        
        placeholderLbl.isHidden = false
        
        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        
        let placeholderFontSize = self.view.frame.size.width / 25
        
        placeholderLbl.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        placeholderLbl.text = "Write a message"
        placeholderLbl.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
        placeholderLbl.textColor = .lightGray
        placeholderLbl.textAlignment = .left
        
        inputTextView.addSubview(placeholderLbl)
        
        
    }
    
    func setupNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containerView.addSubview(avatarImageView)
        
        let leftBarButtonItem = UIBarButtonItem(customView: containerView)
        self.navigationItem.leftItemsSupplementBackButton = true //not allow to overriding the natural back button
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
       // print(self.navigationItem.leftBarButtonItem)
        
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        
        let attributed = NSMutableAttributedString(string: partnerUsername + "\n", attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor : UIColor.black])
        
        attributed.append(NSAttributedString(string: "Dummy Text", attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor : UIColor.green]))
        topLabel.attributedText = attributed
        
        self.navigationItem.titleView = topLabel
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func sendButtonDidTapped(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty{
            let text = textView.text.trimmingCharacters(in: spacing)
            sendButton.isEnabled = true
            sendButton.setTitleColor(.black, for: .normal)
            placeholderLbl.isHidden = true
        } else {
            sendButton.isEnabled = false
            sendButton.setTitleColor(.lightGray, for: .normal)
            placeholderLbl.isHidden = false
        }
    }
}
