//
//  PolicyDetailsVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 12/8/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class PolicyDetailsVC: UIViewController {
    
    var policyNo: String!
    var payerCode: String!
    var payerName: String!
    var context: NSManagedObjectContext!
    var policy: Insured_Policy?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblPolicyNo: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblPatientShare: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //lblPolicyNo.text = policyNo
        lblCompanyName.text = payerName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var resultUpdated = false
        (policy, resultUpdated) = loadPolicy()
        let detailedPolicy = resultUpdated ? policy : loadDetails()
        policy = detailedPolicy == nil ? policy : detailedPolicy
        
        lblShare.text = lblShare.text?.localized()
        
        if Localize.currentLanguage() == "ar" {
            lblShare.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15.0)
        } else {
            lblShare.font = UIFont(name: "AvenirNextCondensed-Medium", size: 15.0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPolicy() -> (Insured_Policy?, Bool) {
        if let policy = Insurances.findPolicy(policyNo: self.policyNo, payerCode: self.payerCode, context: self.context) {
            if let share = policy.share_amount, !share.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if let type = policy.share_type {
                    self.lblPatientShare.text = "\(share) \(type)"
                } else {
                    self.lblPatientShare.text = share
                }
                if let holder = policy.policy_holder, !holder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.lblCompanyName.text = holder
                }
                return (policy, true)
            }
        }
        return (policy, false)
    }
    
    func loadDetails() -> Insured_Policy? {
        var policy: Insured_Policy?
        if let found = Insurances.canDetailsFetch(context: self.context, policyNo: self.policyNo, payerCode: self.payerCode) {
            self.activityIndicator.startAnimating()
            let cardNo = found.member_id
            let policyNo = found.policy_no
            let payerCode = found.company_code
            let providerId = found.id
            let departmentCode = found.department_code
            Insurances.details(providerId: providerId!, cardNo: cardNo!, policyNo: policyNo!, departmentCode: departmentCode!, payerCode: payerCode!, completion: {(result, error) -> Void in
                self.activityIndicator.stopAnimating()
                if error != nil
                {
                    let alert = UIAlertController(title: "Problem getting details", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    //self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                }
                else {
                    policy =  Insurances.updatePolicy(context: self.context, policyNo: self.policyNo, payerCode: self.payerCode, policy: result!)
                    if let share = policy?.share_amount, !share.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if let type = policy?.share_type {
                            self.lblPatientShare.text = "\(share) \(type)"
                        } else {
                            self.lblPatientShare.text = share
                        }
                        if let holder = policy?.policy_holder, !holder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.lblCompanyName.text = holder
                        }
                    }
                }
            })
        }
        return policy
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
