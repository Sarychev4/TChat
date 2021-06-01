//
//  TableTableViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 28.04.21.
//

import UIKit
import FirebaseAuth

class MessagesTableViewController: UITableViewController {

    var inboxArray = [Inbox]()
    
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    
    var lastInboxDate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        observeInbox()
        
    }
    
    func setupNavigationBar(){
        //navigationItem.backButtonTitle = "" //Hide back title in ChatVC
        //navigationController?.navigationBar.backgroundColor = UIColor.blue
        navigationItem.title = "Voices"
        navigationController?.navigationBar.prefersLargeTitles = true
      //  navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 5/255, green: 132/255, blue: 254/255, alpha: 1.0)]
       // let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        //avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
       // containerView.addSubview(avatarImageView)

      //  let leftBarButtonItem = UIBarButtonItem(customView: containerView)
       // self.navigationItem.leftItemsSupplementBackButton = true //not allow to overriding the natural back button
      //  self.navigationItem.leftBarButtonItem = leftBarButtonItem

        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            avatarImageView.loadImage(photoUrl.absoluteString)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name("updateProfileImage"), object: nil)
//
    }
    
    @objc func updateProfile(){
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            avatarImageView.loadImage(photoUrl.absoluteString)
        }
    }
    
    func observeInbox(){
        Api.Inbox.lastMessages(uid: Api.User.currentUserId) { (inbox) in
            if !self.inboxArray.contains(where: { $0.user.uid == inbox.user.uid}){
                self.inboxArray.append(inbox)
                self.sortedInbox()
            }
        }
    }
    
    func sortedInbox(){
        inboxArray = inboxArray.sorted(by: { $0.date > $1.date })
        lastInboxDate = inboxArray.last!.date
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadMore() {
        Api.Inbox.loadMore(start: lastInboxDate, controller: self, from: Api.User.currentUserId) { (inbox) in
            self.tableView.tableFooterView = UIView()
            if self.inboxArray.contains(where: {$0.channel == inbox.channel}) {
                return
            }
            self.inboxArray.append(inbox)
            self.tableView.reloadData()
            self.lastInboxDate = self.inboxArray.last!.date
        }
    }
    
    func setupTableView(){
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
//    @IBAction func logoutAction(_ sender: Any) {
//        Api.User.logOut()
//    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inboxArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell

        let inbox = self.inboxArray[indexPath.row]
        cell.controller = self
        cell.configureCell(uid: Api.User.currentUserId, inbox: inbox, currentImage: avatarImageView.image!, samples: inbox.samples)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell{
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.imagePartner = cell.avatar.image
            chatVC.currentUserImage = cell.currentUserImage
            chatVC.partnerUsername = cell.usernameLbl.text
            chatVC.partnerId = cell.user.uid
            chatVC.partnerUser = cell.user
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.row >= self.inboxArray.count - 2 {
                let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.loadMore()
                }
            }
        }
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
