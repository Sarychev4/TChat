//
//  UserTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 29.04.21.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadData(_ user: User){
        self.avatar.image = UIImage(named: "SarychevAvatar")
        self.usernameLbl.text = user.username
        self.statusLbl.text = user.status
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
