//
//  PolicyCell.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/16/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class PolicyCell: UITableViewCell {
    
    @IBOutlet weak var lblPolicyTitle: UILabel!
    @IBOutlet weak var lblPolicyNumber: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var btnDetails: UIButton!
    var payerCode: String!
    var delegate: PolicyMenuDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func options(_ sender: UIButton) {
        delegate?.show(policyNo: self.lblPolicyNumber.text!, payerCode: self.payerCode!, payerName: self.lblCompanyName.text!, anchor: btnDetails)
    }

}
