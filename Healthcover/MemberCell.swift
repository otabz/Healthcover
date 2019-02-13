//
//  MemberCell.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/16/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblInsurerType: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
