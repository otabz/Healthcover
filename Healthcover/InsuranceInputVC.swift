//
//  InsuranceInputVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/2/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Localize_Swift

class InsuranceInputVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtCardNo: UITextField!
    @IBOutlet weak var txtPolicyNo: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewCardNo: UIView!
    @IBOutlet weak var viewPolicyNo: UIView!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblPolicyNo: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewMatches: UITableView!
    @IBOutlet weak var tableViewMatchesCard: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnContinue1: UIButton!

    var payers = [Payer]()
    var result = false
    var resultedInsurance: Insurances.Member?
    var autoCompletePolicyPossibilities = [String]()
    var autoCompleteCardPossibilities = [String]()
    var autoCompletePolicy = [String]()
    var autoCompleteCard = [String]()
    var unwindTo: String = ""
    var insuranceUpdateDelegate: InsuranceUpdateDelegate?
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtCardNo.delegate = self
        txtPolicyNo.delegate = self
        let tapOnTable = UITapGestureRecognizer.init(target: self, action: #selector(InsuranceInputVC.dismissKeyboard))
        tapOnTable.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapOnTable)
        fetchPolicyPossibilities()
        fetchCardPossibilities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblHeader.text = lblHeader.text?.localized()
        if Localize.currentLanguage() == "ar" {
            lblHeader.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22.0)
            txtPolicyNo.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22.0)
            txtCardNo.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22.0)
            lblCardNo.font = UIFont(name: "AvenirNextCondensed-Regular", size: 16.0)
            lblPolicyNo.font = UIFont(name: "AvenirNextCondensed-Regular", size: 16.0)
        } else {
            lblHeader.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22.0)
            txtPolicyNo.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22.0)
            txtCardNo.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22.0)
            lblCardNo.font = UIFont(name: "AvenirNextCondensed-Medium", size: 16.0)
            lblPolicyNo.font = UIFont(name: "AvenirNextCondensed-Medium", size: 16.0)
        }
        txtCardNo.placeholder = txtCardNo.placeholder?.localized()
        txtPolicyNo.placeholder = txtPolicyNo.placeholder?.localized()
        lblCardNo.text = lblCardNo.text?.localized()
        lblPolicyNo.text = lblPolicyNo.text?.localized()
        btnContinue1.setTitle(btnContinue1.title(for: .normal)?.localized(), for: .normal)
    }
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selection, animated: true)
        }
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtPolicyNo {
            self.tableViewMatchesCard.isHidden = true
        } else if textField == self.txtCardNo {
            self.tableViewMatches.isHidden = true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPolicyNo {
            let subString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            searchAutocompleteEntriesWithSubstringPolicy(subString: subString)
        } else if textField == self.txtCardNo {
            let subString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            searchAutocompleteEntriesWithSubstringCard(subString: subString)
        }
        return true
    }
    
    func searchAutocompleteEntriesWithSubstringPolicy(subString: String) {
        autoCompletePolicy.removeAll(keepingCapacity: false)
        
        for key in autoCompletePolicyPossibilities {
            let myString: NSString! = key as NSString
            let subStringRange: NSRange! = myString.range(of: subString)
            if subStringRange.location == 0{
                autoCompletePolicy.append(key)
            }
        }
        if autoCompletePolicy.count > 0 {
            self.tableViewMatches.isHidden = false
        } else {
            self.tableViewMatches.isHidden = true
        }
        tableViewMatches.reloadData()
    }
    
    func searchAutocompleteEntriesWithSubstringCard(subString: String) {
        autoCompleteCard.removeAll(keepingCapacity: false)
        
        for key in autoCompleteCardPossibilities {
            let myString: NSString! = key as NSString
            let subStringRange: NSRange! = myString.range(of: subString)
            if subStringRange.location == 0{
                autoCompleteCard.append(key)
            }
        }
        if autoCompleteCard.count > 0 {
            self.tableViewMatchesCard.isHidden = false
        } else {
            self.tableViewMatchesCard.isHidden = true
        }
        tableViewMatchesCard.reloadData()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func validateInput(_ sender: UIButton) {
        if !validate(cardNo: txtCardNo.text!, policyNo: txtPolicyNo.text!) {
            return
        }
        dismissKeyboard()
        sender.isHidden = true
        payers = Payers.list()
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func validate(cardNo: String, policyNo: String) -> Bool {
        var result = true
        if cardNo.isEmpty {
            /*txtCardNo.layer.borderWidth = 0.5
            txtCardNo.layer.cornerRadius = 5.0
            txtCardNo.layer.borderColor = UIColor.red.cgColor
            viewCardNo.backgroundColor = UIColor.red*/
            lblCardNo.textColor = UIColor.red
            result = false
        } else {
            lblCardNo.textColor = UIColor.darkGray

        }
        if policyNo.isEmpty {
            /*txtPolicyNo.layer.borderWidth = 0.5
            txtPolicyNo.layer.cornerRadius = 5.0
            txtPolicyNo.layer.borderColor = UIColor.red.cgColor
            viewPolicyNo.backgroundColor = UIColor.red*/
            lblPolicyNo.textColor = UIColor.red
            result = false
        } else {
            lblPolicyNo.textColor = UIColor.darkGray
        }
        return result
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewMatches{
            return autoCompletePolicy.count
        } else if tableView == self.tableViewMatchesCard {
            return autoCompleteCard.count
        }
        return payers.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewMatches {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
            cell.textLabel?.text = autoCompletePolicy[indexPath.row]
            return cell
        } else if tableView == self.tableViewMatchesCard {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
            cell.textLabel?.text = autoCompleteCard[indexPath.row]
            return cell
        }
        let cell:PayersCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PayersCell!
        
        cell.lblEnName.text = payers[indexPath.row].enName
        cell.lblArName.text = payers[indexPath.row].arName
        cell.code = payers[indexPath.row].portalCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewMatches {
            let selectedCell = tableView.cellForRow(at: indexPath)!
            self.txtPolicyNo.text = selectedCell.textLabel?.text
            self.tableViewMatches.isHidden = true
        } else if tableView == self.tableViewMatchesCard {
            let selectedCell = tableView.cellForRow(at: indexPath)!
            self.txtCardNo.text = selectedCell.textLabel?.text
            self.tableViewMatchesCard.isHidden = true
        } else {
            check()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController!) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func unwindToInsuranceInput(segue: UIStoryboardSegue) {
    }
    
    @IBAction func exit(_ sender: UIButton) {
        if self.activityIndicator.isAnimating {
            return
        }
        self.performSegue(withIdentifier: self.unwindTo, sender: self)
    }
    
    @objc func dismissKeyboard() {
        if txtCardNo.isFirstResponder {
            txtCardNo.resignFirstResponder()
        } else if txtPolicyNo.isFirstResponder {
            txtPolicyNo.resignFirstResponder()
        }
        self.tableViewMatches.isHidden = true
        self.tableViewMatchesCard.isHidden = true
    }
    
    func check() {
        // request params
        let cardNo = txtCardNo.text!
        let policyNo = txtPolicyNo.text!
        let payer = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! PayersCell)
        let payerNameEn = payer.lblEnName.text!
        let payerNameAr = payer.lblArName.text!
        let payerCode = payer.code!
        
        // client validate
        if !validate(cardNo: cardNo, policyNo: policyNo) {
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            return
        }
        
        // already exist
        if duplicate(policyNo: policyNo, cardNo: cardNo, payerCode: payerCode) {
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            return
        }
        
        // server validation
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Insurances.check(cardNo: cardNo, policyNo: policyNo, payerNameEn: payerNameEn, payerNameAr: payerNameAr, payerCode: payerCode, completion: {(result, error) -> Void in
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if error != nil
            {
                let alert = UIAlertController(title: "Problem validating info".localized(), message: error?.localizedDescription.localized(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            }
            else {
                if self.isNameRetrieved(result: result){
                    self.save(result: result)
                } else {
                    self.saveWithAskedName(result: result)
                }
            }
        })
    }
    
    func duplicate(policyNo: String, cardNo: String, payerCode: String) -> Bool {
        if let member = Insurances.findMember(policyNo: policyNo, cardNo: cardNo, payerCode: payerCode, context: self.context) {
            let alert = UIAlertController(title: "Already existing member".localized(), message: "\("Given info already exist for,  \n".localized())\(member.name!)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func isNameRetrieved(result: Insurances.Policy?) -> Bool {
        if let name = result?.members?[0].name, !name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return true
        }
        return false
    }
    
    func saveWithAskedName(result: Insurances.Policy?) {
        let alert = UIAlertController(title: "Enter Name".localized(), message: "We couldn't retrieve your name\nTo proceed, please enter your name".localized(), preferredStyle:
            UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) in
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction) in
            if let name = alert.textFields?[0].text, name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                self.present(alert, animated: true, completion: nil)
            } else {
                let name = alert.textFields?[0].text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                result?.members?[0].name = name!
                self.save(result: result)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(result: Insurances.Policy?) {
        if Insurances.findPolicy(policyNo: (result?.id)!, payerCode: (result?.companyCode)!, context: self.context) != nil {
            self.result = Insurances.insert(data: result?.members?[0], context: self.context)
            self.resultedInsurance = result?.members?[0]
            self.performSegue(withIdentifier: self.unwindTo, sender: self)
            if let delegate = self.insuranceUpdateDelegate {
                delegate.updated()
            }
        } else if Insurances.insert(data: result, context: self.context) {
            self.result = Insurances.insert(data: result?.members?[0], context: self.context)
            self.resultedInsurance = result?.members?[0]
             self.performSegue(withIdentifier: self.unwindTo, sender: self)
            if let delegate = self.insuranceUpdateDelegate {
                delegate.updated()
            }
        }
    }
    
    func fetchPolicyPossibilities() {
        autoCompletePolicyPossibilities.removeAll(keepingCapacity: false)
        if let policies = Insurances.listPolicies(context: self.context) {
            for policy: Insured_Policy in policies {
                autoCompletePolicyPossibilities.append(policy.policy_no!)
            }
        }
    }
    
    func fetchCardPossibilities() {
        autoCompleteCardPossibilities.removeAll(keepingCapacity: false)
        if let cards = Insurances.listAllMembers(context: self.context) {
            for card: Insured_Member in cards {
                autoCompleteCardPossibilities.append(card.member_no!)
            }
        }
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
