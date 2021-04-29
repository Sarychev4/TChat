//
//  PeopleTableViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 29.04.21.
//

import UIKit

class PeopleTableViewController: UITableViewController {
    
    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Ref().databaseRoot.ref.description())
        print(Ref().databaseUsers.ref.description())
        Ref().databaseUsers.observe(.childAdded) { (snaphot) in
            //           print(snaphot.value)
            if let dict = snaphot.value as? Dictionary<String, Any> {
                //                let email = dict["email"] as! String
                //                let username = dict["username"] as! String
                //                print(email)
                //                print(username)
                if let user = User.transformUser(dict: dict){
                    self.users.append(user)
                }
                self.tableView.reloadData() //reloads rows and sections
            }
        }
    }
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell
        // Configure the cell...
        let user = users[indexPath.row]
        cell.loadData(user)
        cell.avatar.layer.cornerRadius = 30
        cell.avatar.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
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
