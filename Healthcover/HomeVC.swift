//
//  HomeVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/2/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

protocol InsuranceUpdateDelegate: class {
    func updated()
}

protocol PolicyMenuDelegate: class {
    func show(policyNo: String, payerCode: String, payerName: String, anchor: UIView)
}

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, FindDelegate, InsuranceUpdateDelegate, PolicyMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let primaryImage = #imageLiteral(resourceName: "img_primary")
    let spouseImage = #imageLiteral(resourceName: "img_spouse")
    let dependentImage = #imageLiteral(resourceName: "img_boy")
    @IBOutlet weak var viewSearchButton: UIView!
    @IBOutlet weak var lblBtnSearch: UILabel!
    var detailsAnchor: UIView?
    var detailsForPolicy: String?
    var detailsForPayerCode: String?
    var detailsForPayerName: String?
    
    var policies : [Insurances.Policy]!
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*let prefs = UserDefaults.standard
        if let _ = prefs.string(forKey: "userAgreedToContinue"){
            
        } else {
           self.performSegue(withIdentifier: "toInsuranceInput", sender: self) 
        }*/
        self.lblBtnSearch.text = self.lblBtnSearch.text?.localized()
        if Localize.currentLanguage() == "ar" {
            self.lblBtnSearch.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        } else {
            self.lblBtnSearch.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        }
        policies = Insurances.list(context: self.context)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findWithCoverage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toWithCoverage", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return policies.count
        //return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        policies[section].members = policies[section].members?.sorted { $0.priority < $1.priority }
        if let count = policies[section].members?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  header = tableView.dequeueReusableCell(withIdentifier: "header") as! PolicyCell
        //header.lblPolicyTitle.text = "POLICY INFORMATION"
        header.lblPolicyNumber.text = policies[section].id
        if  Localize.currentLanguage() == "ar" {
            header.lblCompanyName.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22.0)
            header.lblCompanyName.text = policies[section].companyNameAr
        } else {
            header.lblCompanyName.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22.0)
            header.lblCompanyName.text = policies[section].companyNameEn
        }
        header.payerCode = policies[section].companyCode
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 101.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! MemberCell
        let member = policies[indexPath.section].members?[indexPath.row]
        cell.lblCardNo.text = member?.id
        cell.lblInsurerType.text = member?.name
        if let type = member?.relationEn {
            if "PRINCIPAL".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                cell.imgAvatar.image = self.primaryImage
            } else if "WIFE".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                cell.imgAvatar.image = self.spouseImage
            } else if "DEPENDENT".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                cell.imgAvatar.image = self.dependentImage
            } else {
                cell.imgAvatar.image = self.dependentImage
            }
        } else {
            cell.imgAvatar.image = self.dependentImage
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    @IBAction func toFind(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "toSearchSuggestion", sender: self)
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddInsurance" {
            let vc = segue.destination as! InsuranceInputVC
            vc.unwindTo = "backToHome"
        } else if segue.identifier == "toSearchSuggestion" {
            let nvc = segue.destination as! UINavigationController
            let vc = nvc.topViewController as! SearchSuggestionVC
            nvc.modalPresentationStyle = UIModalPresentationStyle.popover
            nvc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height/2)
            nvc.popoverPresentationController?.delegate = self
            vc.findDelegate = self
            vc.insuranceUpdateDelegate = self
        } else if segue.identifier == "toDetails" {
            let vc = segue.destination as! PolicyDetailsVC
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:100)
            vc.policyNo = self.detailsForPolicy
            vc.payerCode = self.detailsForPayerCode
            vc.payerName = self.detailsForPayerName
            vc.context = self.context
            if let pop = vc.popoverPresentationController {
                pop.delegate = self
                pop.sourceView = self.detailsAnchor!
                pop.sourceRect = self.detailsAnchor!.bounds
            }
        }
    }
    
    func find() {
        self.performSegue(withIdentifier: "toFind", sender: self)
    }
    
    func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func updated() {
        viewWillAppear(false)
    }
    
    func show(policyNo: String, payerCode: String, payerName: String, anchor: UIView) {
        self.detailsForPolicy = policyNo
        self.detailsForPayerCode = payerCode
        self.detailsForPayerName = payerName
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // 2
        let detailsAction = UIAlertAction(title: "Details".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.detailsAnchor = anchor
            self.performSegue(withIdentifier: "toDetails", sender: self)
            
            /*if let found = Insurances.canDetailsFetch(context: self.context, policyNo: policyNo, payerCode: payerCode) {
                let cardNo = found.member_id
                let policyNo = found.policy_no
                let payerCode = found.company_code
                let providerId = found.id
                let departmentCode = found.department_code
                Insurances.details(providerId: providerId!, cardNo: cardNo!, policyNo: policyNo!, departmentCode: departmentCode!, payerCode: payerCode!, completion: {(result, error) -> Void in
                    //self.activityIndicator.stopAnimating()
                    if error != nil
                    {
                        let alert = UIAlertController(title: "Problem getting details", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        //self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                    else {
                        print("successful")
                    }
                })
            }*/
        })
        
        let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            let title = "Are you sure, you want to delete policy".localized()
            let alert = UIAlertController(title: "\(title) \(policyNo)", message: "All data will be deleted and you won't be able to recover it later.".localized(), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { (action: UIAlertAction!) in
                Insurances.deletePolicy(context: self.context, policyNo: self.detailsForPolicy!, payerCode: self.detailsForPayerCode!)
                Insurances.selectedInsurance = nil
                self.viewWillAppear(true)
            }))
            self.present(alert, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // 4
        optionMenu.addAction(detailsAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
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
/*
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
*/
