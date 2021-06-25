//
//  TableTableViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 28.04.21.
//

import UIKit
import FirebaseAuth
import Firebase
import Kingfisher

class InboxListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var inboxArray: [Inbox] = []
    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        observeInboxes()
        
    }
    
    func setupNavigationBar(){
        //navigationItem.backButtonTitle = "" //Hide back title in ChatVC
        //navigationController?.navigationBar.backgroundColor = UIColor.blue
        navigationItem.title = "Voices"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            //avatarImageView.kf.setImage(with: URL(string: partnerUser.profileImageUrl)!)
            //self.avatarImageView.loadImage(user.profileImageUrl)
            self.avatarImageView.kf.setImage(with: URL(string: user.profileImageUrl)!)
        }
     
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name("updateProfileImage"), object: nil)
        //
    }
    
    @objc func updateProfile() {
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            avatarImageView.loadImage(photoUrl.absoluteString)
        }
    }
    
    func observeInboxes() {
        Api.Inbox.observeInboxes() { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.inboxArray = LocalCacheService.shared.inboxes
                self.tableView.reloadData()
            }
        }
    }
    
    func loadMore() {
//        let lastInboxDate = inboxArray.first?.lastMessageDate
//        Api.Inbox.loadMore(start: lastInboxDate, controller: self, from: Api.User.currentUserId) { (inbox) in
//            self.inboxArray.append(inbox)
//            self.tableView.reloadData()
//        }
    }
    
    func setupTableView(){
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    //    @IBAction func logoutAction(_ sender: Any) {
    //        Api.User.logOut()
    //    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inboxArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell
        let inbox = self.inboxArray[indexPath.row]
        cell.controller = self
        cell.configureCell(uid: Api.User.currentUserId, inbox: inbox, currentImage: avatarImageView.image)
        return cell
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell{
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.currentUserImage = avatarImageView.image
            chatVC.partnerUsername = cell.usernameLbl.text
            chatVC.partnerId = cell.user.uid
            chatVC.partnerUser = cell.user
            chatVC.dialogId = cell.inbox.id
            chatVC.lastMessageId = cell.inbox.lastMessageId
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.row >= self.inboxArray.count - 2 {
                //let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                self.spinner.startAnimating()
                self.spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.loadMore()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.spinner.stopAnimating()
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
