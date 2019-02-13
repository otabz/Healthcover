//
//  SelectInsuranceVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/20/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class SelectInsuranceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let primaryImage = #imageLiteral(resourceName: "img_primary")
    let spouseImage = #imageLiteral(resourceName: "img_spouse")
    let dependentImage = #imageLiteral(resourceName: "img_boy")
    var policies : [Insurances.Policy] = [Insurances.testPolicy()]
    var selection : Insurances.Member?
    var insuranceUpdateDelegate: InsuranceUpdateDelegate?

    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !isAnyInsurance() {
            //self.performSegue(withIdentifier: "toAddInsurance", sender: self)
            let alert = UIAlertController(title: "Couldn't find your health insurance info.".localized(), message: "To proceed, please provide your health insurance info.".localized(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Continue".localized(), style: UIAlertAction.Style.cancel,  handler:{ (UIAlertAction) in
                self.performSegue(withIdentifier: "toAddInsurance", sender: self)
            }))
           
            alert.addAction(UIAlertAction(title: "Not now".localized(), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) in
                _=self.navigationController?.popViewController(animated: false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Select Member".localized()
        policies = Insurances.list(context: self.context)
        tableView.reloadData()
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
        if Localize.currentLanguage() == "ar" {
            header.lblCompanyName.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22.0)
            header.lblCompanyName.text = policies[section].companyNameAr
        } else {
            header.lblCompanyName.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22.0)
            header.lblCompanyName.text = policies[section].companyNameEn
        }
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
        
        if highlight(cell: policies[indexPath.section].members![indexPath.row]) {
            cell.lblInsurerType.textColor = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1.0)
        } else {
            cell.lblInsurerType.textColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selection = policies[indexPath.section].members?[indexPath.row]
        Insurances.selectedInsurance = self.selection
        self.performSegue(withIdentifier: "selected", sender: self)
    }

    func highlight(cell: Insurances.Member)-> Bool {
        if cell.id == self.selection?.id && cell.companyCode == self.selection?.companyCode {
            return true
        }
        return false
    }
    
    @IBAction func unwindToSelectInsurance(segue: UIStoryboardSegue) {
        if segue.source.isKind(of: InsuranceInputVC.self) {
            if !isAnyInsurance() {
                _ = self.navigationController?.popViewController(animated: false)
            } else {
                let vc = segue.source as! InsuranceInputVC
                if vc.result {
                    Insurances.selectedInsurance = vc.resultedInsurance
                    self.selection = vc.resultedInsurance
                    _=self.navigationController?.popViewController(animated: false)
                    //self.performSegue(withIdentifier: "selected", sender: self)
                }
            }
        }
    }
    
    func isAnyInsurance()-> Bool {
        let request: NSFetchRequest<Insured_Policy> = Insured_Policy.fetchRequest()
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return true
            }
        } catch {
            print("Error with request: \(error)")
        }
        return false
    }

    @IBAction func addInsurance(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "toAddInsurance", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddInsurance" {
            let vc = segue.destination as! InsuranceInputVC
            vc.unwindTo = "backToSelection"
            vc.insuranceUpdateDelegate = self.insuranceUpdateDelegate
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
