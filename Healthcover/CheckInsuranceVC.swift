//
//  CheckInsuranceVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/20/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

protocol SetCoverageDelegate: class {
    func set(selectedInsurance: Insurances.Member, selectedDepartment: Insurances.Department)
}
class CheckInsuranceVC: UIViewController {

    
    var selectedInsurance: Insurances.Member?
    var selectedDepartmet: Insurances.Department?
    var selectedProvider: String?
    var url: String?
    var coverageRetryDelegate: CoverageRetryDelegate?
    
    @IBOutlet weak var btnSelectInsurance: UIButton!
    @IBOutlet weak var btnSelectDepartment: UIButton!
    @IBOutlet weak var viewSeparator1: UIView!
    @IBOutlet weak var viewSeparator2: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewResult: UIView!
    @IBOutlet weak var imgResult: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblResultDesc: UILabel!
    @IBOutlet weak var btnCheck: UIButton!
    
    var setCoverageDelegate: SetCoverageDelegate?
    var btnName = "Check"
    var insuranceUpdateDelegate: InsuranceUpdateDelegate?
    //var isChangeInVisitInfoAllowed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "statusbar_green"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        btnSelectInsurance.isEnabled = (coverageRetryDelegate != nil) ? false : true
        btnSelectDepartment.isEnabled = (coverageRetryDelegate != nil) ? false : true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.selectedInsurance = Insurances.selectedInsurance
        self.selectedDepartmet = Insurances.selectedDepartment

        if self.selectedInsurance != nil {
            btnSelectInsurance.setTitle(selectedInsurance?.name, for: .normal)
            btnSelectInsurance.setTitleColor(UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1.0), for: .normal)
        } else {
            btnSelectInsurance.setTitle("Select Insurance".localized(), for: .normal)
            btnSelectInsurance.setTitleColor(UIColor.lightGray, for: .normal)
        }
        
        if selectedDepartmet != nil {
            btnSelectDepartment.setTitle(Localize.currentLanguage() == "en" ? selectedDepartmet?.name : selectedDepartmet?.nameAr, for: .normal)
            btnSelectDepartment.setTitleColor(UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1.0), for: .normal)
       } else {
        btnSelectDepartment.setTitle("Select Department".localized(), for: .normal)
            btnSelectDepartment.setTitleColor(UIColor.lightGray, for: .normal)
        }
        _=validate()
        viewResult.isHidden = true
        /*if self.setCoverageDelegate == nil {
            self.btnCheck.setTitle("Check", for: .normal)
        } else {
            self.btnCheck.setTitle("Set", for: .normal)
        }*/
        self.btnCheck.setTitle(self.btnName.localized(), for: .normal)
        self.title = "Check Coverage".localized()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectInsurance(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSelectInsurance", sender: self)
    }
    @IBAction func toInsurance(_ sender: UIButton) {
         self.performSegue(withIdentifier: "toSelectInsurance", sender: self)
    }
    @IBAction func selectDepartment(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSelectDepartment", sender: self)
    }
    @IBAction func toDepartment(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSelectDepartment", sender: self)
    }
    @IBAction func check(_ sender: UIButton) {
        if !validate() {
            return
        }
        if let delegate = self.setCoverageDelegate {
            self.dismiss(animated: true, completion: {
                delegate.set(selectedInsurance: self.selectedInsurance!, selectedDepartment: self.selectedDepartmet!)
            })
        } else {
            //viewResult.isHidden = false
            if self.activityIndicator.isHidden {
            check()
            }
        }
    }
    
    func check() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let cardNo = self.selectedInsurance?.id
        let policyNo = self.selectedInsurance?.policyNo
        let payerCode = self.selectedInsurance?.companyCode
        let department = self.selectedDepartmet?.code
        Insurances.eligibility(url: url, cardNo: cardNo!, policyNo: policyNo!, payerCode: payerCode!, department: department!, completion: {(result, error) -> Void in
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if error != nil
            {
                self.imgResult.image = #imageLiteral(resourceName: "img_eligible_not")
                self.lblResult.text = error?.localizedDescription
                self.lblResultDesc.text = "You can contact Waseel for further info.".localized()
            }
            else if result?.caseInsensitiveCompare("ELIGIBLE") == ComparisonResult.orderedSame {
               self.imgResult.image = #imageLiteral(resourceName: "img_eligible")
                self.lblResult.text = result
                self.lblResultDesc.text = "But service coverage may vary.".localized()
                self.coverageRetryDelegate?.retried()
            } else {
                self.imgResult.image = #imageLiteral(resourceName: "img_eligible_not")
                self.lblResult.text = result
                self.lblResultDesc.text = "You can contact Waseel for further info.".localized()
            }
            if Localize.currentLanguage() == "ar" {
                self.changeFontToRegular(regular: true)
            } else {
                self.changeFontToRegular(regular: false)
            }
            self.viewResult.isHidden = false
        })
    }
    
    func changeFontToRegular(regular: Bool) {
        if regular {
         lblResult.font = UIFont(name: "AvenirNextCondensed-Regular", size: 19.0)
         lblResultDesc.font = UIFont(name: "AvenirNextCondensed-Regular", size: 17.0)
        } else {
            lblResult.font = UIFont(name: "AvenirNextCondensed-Medium", size: 19.0)
            lblResultDesc.font = UIFont(name: "AvenirNextCondensed-Medium", size: 17.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectInsurance" {
            let vc = segue.destination as! SelectInsuranceVC
            vc.selection = self.selectedInsurance
            vc.insuranceUpdateDelegate = self.insuranceUpdateDelegate
        }
        else if segue.identifier == "toSelectDepartment" {
            let vc = segue.destination as! SelectDepartmentVC
            vc.selection = self.selectedDepartmet
        }
    }
    
    func validate() -> Bool {
        var result = true
        if selectedInsurance == nil {
            //viewSeparator1.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            result = false
        } else {
            //viewSeparator1.backgroundColor = UIColor.groupTableViewBackground
        }
        if selectedDepartmet == nil  {
            //viewSeparator2.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            result = false
        } else {
           //viewSeparator2.backgroundColor = UIColor.groupTableViewBackground
        }
        if result {
            btnCheck.isHidden = false
        }
        return result
    }
    
    @IBAction func unwindToChecInsurance(segue: UIStoryboardSegue) {
        if segue.source.isKind(of: SelectInsuranceVC.self) {
            /*let vc = segue.source as! SelectInsuranceVC*/
            
            //viewResult.isHidden = true
           // _ = validate()
        } else if segue.source.isKind(of: SelectDepartmentVC.self) {
            //let vc = segue.source as! SelectDepartmentVC
            //self.selectedDepartmet =  vc.selection
            //viewResult.isHidden = true
             //_ = validate()
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
