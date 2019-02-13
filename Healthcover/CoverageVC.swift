//
//  CoverageVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/7/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Localize_Swift


protocol CoverageRetryDelegate: class {
    func retried()
}

class CoverageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SetCoverageDelegate, CLLocationManagerDelegate, CoverageRetryDelegate {

    //let imgCovered = UIImageView(image: #imageLiteral(resourceName: "img_eligible"))
    //let imgNotCovered  = UIImageView(image: #imageLiteral(resourceName: "img_eligible_not"))
    
    var founds: Array<NearBySearchResult.Result>?
    var nextPage: String?
    
    //var nearby = [Provider]()
    //var covered = [Provider]()
    var selectedCriteria: Search.SearchCiteria = Search.DefaultCriterias[0]
    var selectedInsurance: Insurances.Member?
    var selectedDepartment: Insurances.Department?
    var selectedProvider: NearBySearchResult.Result?
    var btnName: String?
    var lat = 41.908
    var lng = 25.000
    var locationManager = CLLocationManager()
    var coveragePopoverForSet = false
    var requireRetryDelegate = false
    //var searches: Search?
    
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var switchArroundMe: UISwitch!
    @IBOutlet weak var lblSearchTitle: UILabel!
    @IBOutlet weak var btnCoverage: UIButton!
    @IBOutlet weak var switchCoverage: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnSearchCriteria: UIButton!
    @IBOutlet weak var lblCurrentLoc: UILabel!
    @IBOutlet weak var lblWithInsurance: UILabel!
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*let prefs = UserDefaults.standard
        if let _ = prefs.string(forKey: "primaryCardNo"){
            
        } else {
            self.performSegue(withIdentifier: "toInsurance", sender: self)
        }*/
        //self.lblSearchTitle.text = self.selectedCriteria.title
        //self.lblSearchSubTitle.text = self.selectedCriteria.subTitle
        list()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Find Hospitals & Clinics".localized()
        lblCurrentLoc.text = lblCurrentLoc.text?.localized()
        lblWithInsurance.text = lblWithInsurance.text?.localized()
        btnMore.setTitle(btnMore.title(for: .normal)?.localized(), for: .normal)
        if Localize.currentLanguage() == "ar" {
            lblCurrentLoc.font = UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)
            lblWithInsurance.font = UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)
            lblSearchTitle.text = selectedCriteria.arTitle
        } else {
            lblCurrentLoc.font = UIFont(name: "AvenirNextCondensed-Medium", size: 20.0)
            lblWithInsurance.font = UIFont(name: "AvenirNextCondensed-Medium", size: 20.0)
            lblSearchTitle.text = selectedCriteria.title
        }
    }
    
    @IBAction func unwindToCoverage(segue: UIStoryboardSegue) {
        if segue.identifier == "exitForCoverage" {
            let vc = segue.source as! SearchCriteriaVC
            self.selectedCriteria = vc.selection!
            if Localize.currentLanguage() == "en" {
                self.lblSearchTitle.text = self.selectedCriteria.title
            } else {
                self.lblSearchTitle.text = self.selectedCriteria.arTitle
            }
            list()
        }
    }
    
    func list() {
        if self.activityIndicator.isHidden {
            btnMore.isHidden = true
            search()
        }
    }
    
    func search() {
        let options = Options { builder in
            builder.network = nil
            builder.category = nil
            builder.open = false
            builder.city = City(cityID: self.selectedCriteria.id.description, cityName: self.selectedCriteria.title, cityNameAr: "")
            builder.coverage = switchCoverage.isOn
        }
        
        // near by
        if self.switchArroundMe.isOn {
            let search = Search(location: Location(lat: self.lat, long: self.lng), insurance: selectedInsurance, department: selectedDepartment, options: options)
            
            /* start activity indicator */
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            search?.nearBy(completionHandler: { (result, error) in
                self.resultHandler(result: result, error: error)
            })
        }
        // by city
        else {
            let search = Search(options: options, insurance: selectedInsurance, department: selectedDepartment)
            
            /* start activity indicator */
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            search?.byKeyword(completionHandler: { (result, error) in
                self.resultHandler(result: result, error: error)
            })
        }
    }
    
    func more() {
        
        // near by
        if self.switchArroundMe.isOn {
            let search = Search(location: nil, insurance: selectedInsurance, department: selectedDepartment, options: nil)
            
            /* start activity indicator */
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            search?.nearBy(nextPage: self.nextPage!, completionHandler: { (result, error) in
                self.resultHandlerMore(result: result, error: error)
            })
        }
            // by city
        else {
            let search = Search(options: nil, insurance: selectedInsurance, department: selectedDepartment)
            
            /* start activity indicator */
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            search?.byKeyword(nextPage: self.nextPage!, method: .post, completionHandler: { (result, error) in
                self.resultHandlerMore(result: result, error: error)
            })
        }
        
    }
    
    func resultHandler(result: NearBySearchResult.SearchResult?, error: NSError?) {
        /* user is navigated */
        if self.navigationController?.topViewController != self {
            return
        }
        
        /* stop activity indicator */
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        if error == nil {
             Search.update(cities: result?.cities)
             Payers.update(payers: result?.networks)
             self.founds = result?.results
             self.nextPage = result?.links?.getURL(oneRel: rel.nextPage)
             //self.categories = result?.categories
             self.tableView?.reloadData()
            if self.switchCoverage.isOn {
                Insurances.updatePolicyDetail(context: self.context, policyNo: (self.selectedInsurance?.policyNo!)!, memberId: (self.selectedInsurance?.id)!, departmentCode: (self.selectedDepartment?.code)!, payerCode: (self.selectedInsurance?.companyCode)!, results: result?.results!)
                if let more = nextPage, !more.isEmpty {
                    btnMore.isHidden = false
                }
            }
             //self.enableShowMapViewOption(true)
            //print(result?.results?.count)
            
        } else {
             self.founds = result?.results
             self.nextPage = nil
             self.tableView?.reloadData()
            /*self.networks = result?.networks
             self.categories = result?.categories
             
             self.enableShowMapViewOption(false)*/
            
            let err = error?.localizedDescription
            let alert = UIAlertController(title: err, message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //self.lblError.text = err
            //self.viewError.hidden = false
        }
    }
    
    func resultHandlerMore(result: NearBySearchResult.SearchResult?, error: NSError?) {
        /* user is navigated */
        if self.navigationController?.topViewController != self {
            return
        }
        
        /* stop activity indicator */
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        if error == nil {
            Search.update(cities: result?.cities)
            Payers.update(payers: result?.networks)
            self.append(results: result?.results)
            self.nextPage = result?.links?.getURL(oneRel: rel.nextPage)
            //self.networks = result?.networks
            //self.categories = result?.categories
            self.tableView?.reloadData()
            if self.switchCoverage.isOn {
                Insurances.updatePolicyDetail(context: self.context, policyNo: (self.selectedInsurance?.policyNo!)!, memberId: (self.selectedInsurance?.id)!, departmentCode: (self.selectedDepartment?.code)!, payerCode: (self.selectedInsurance?.companyCode)!, results: result?.results!)
                if let more = nextPage, !more.isEmpty {
                    btnMore.isHidden = false
                }
            }            //self.enableShowMapViewOption(true)
            //print(result?.results?.count)
            
        } else {
            self.founds = result?.results
            self.nextPage = nil
            self.tableView?.reloadData()
            /*self.networks = result?.networks
             self.categories = result?.categories
             
             self.enableShowMapViewOption(false)*/
            
            let err = error?.localizedDescription
            let alert = UIAlertController(title: err, message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //self.lblError.text = err
            //self.viewError.hidden = false
        }

    }
    
    
    func append(results: [NearBySearchResult.Result]?) {
        if results == nil || self.founds == nil {
            return
        }
        for each in results! {
            self.founds?.append(each)
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.founds?.count {
            return count > 0 ? count : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        /*if indexPath.row == 0 {
        cell.textLabel?.text = "Dr. Sulaiman Al Habib"
        cell.detailTextLabel?.text = "You are eligible but service coverage mat vary."
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_eligible"))
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Dallah Hospital"
            cell.detailTextLabel?.text = "Rayan road, Riyadh"
            //cell.accessoryType = .none
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Abad Hospital"
            cell.detailTextLabel?.text = "Oops! problem occurred."
            //cell.accessoryType = .none

        }*/
        if let provider: NearBySearchResult.Result = founds?[indexPath.row] {
            //cell.textLabel?.text = provider.name
            var nameAr = ""
            var detailText = ""
            var text = ""
            if let nm = provider.name {
                text = "\(indexPath.row+1).  \(nm)"
            }
            
            if let ar = provider.nameAr {
                nameAr = ar
            }
            if provider.coverage?.caseInsensitiveCompare("ELIGIBLE") == ComparisonResult.orderedSame {
                detailText = nameAr
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_eligible_text"))
            } else if provider.coverage?.caseInsensitiveCompare("FAILURE") == ComparisonResult.orderedSame  {
                detailText = nameAr
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_error_text"))
            } else if provider.coverage?.caseInsensitiveCompare("INELIGIBLE") == ComparisonResult.orderedSame  {
                detailText = nameAr
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_not_eligible_text"))
            } else if provider.coverage?.caseInsensitiveCompare("INVALID") == ComparisonResult.orderedSame  {
                detailText = nameAr
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_invalid_text"))
            } else {
                detailText = nameAr
                cell.accessoryView = nil
            }
            cell.textLabel?.text = text
            cell.detailTextLabel?.text = detailText
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        requireRetryDelegate = false
        self.selectedProvider = self.founds?[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath), let view = (cell.accessoryView as? UIImageView), view.image == #imageLiteral(resourceName: "img_error_text") {
            showOptions()
        } else {
            self.performSegue(withIdentifier: "toProviderProfile", sender: self)
        }
    }
    
    @IBAction func useMyCurrentLocation(_ sender: UISwitch) {
        //print(sender.isOn)
        if sender.isOn {
            //sender.isOn = false
            findLocation()
        } else {
            switchLocationOff()
        }
    }
    
    func findLocation() {
        if !CLLocationManager.locationServicesEnabled() {
            let alert = UIAlertController (title: "Turn on Location Services to Allow \"Healthcover\" to Determine Your Location".localized(), message: "To find providers around you, Healthcover needs access to your phone's location".localized(), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK".localized(), style: .default) { (_) -> Void in
                //self.navigationController?.popToRootViewControllerAnimated(true)
                self.switchArroundMe.setOn(false, animated: true)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else if locationManager.delegate == nil {
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            //switchLocationOn()
        } else {
          //switchLocationOn()
          locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        lat = coord.latitude
        lng = coord.longitude
        //print(lat)
        switchLocationOn()
        
        /*let geoCoder = CLGeocoder()
         geoCoder.reverseGeocodeLocation(locationObj) { (placemarks, error) -> Void in
         
         if error != nil {
         print("Error getting location: \(error)")
         } else {
         let placeArray = placemarks as [CLPlacemark]!
         var placeMark: CLPlacemark!
         placeMark = placeArray?[0]
         print(placeMark.addressDictionary?["City"] as Any)
         //completion(placeMark.addressDictionary as! Typealiases.JSONDict)
         }
         }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // didFailWithError is triggered when there is a problem with updating user location
        //print("failed user location ...")
        //manager.stopUpdatingLocation()
        
        /* user is navigated */
        if self.navigationController?.topViewController != self {
            return
        }
        /* switch off */
        switchArroundMe.setOn(false, animated: false)
        switchLocationOff()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse
        {
            //if self.navigationController?.topViewController == self {
            let alertController = UIAlertController (title: "Healthcover does not have access to your location".localized(), message: "To enable access, tap Settings > Location".localized(), preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings".localized(), style: .default) { (_) -> Void in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIApplication.shared.open(url, completionHandler: { (success) in
                            //print("Settings opened: \(success)") // Prints true
                        })
                    }                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil);
            //}
            //print("Denied Access: Healthcover does not have access to your location")
        }
        else {
            //print(error.localizedDescription)
            //if self.navigationController?.topViewController == self {
            let alertController = UIAlertController (title: "Cannot determine your current location".localized(), message: "It could be a problem of GPS connectivity, try again while relocating your device".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil);
            //}
            //print("Error while updating locationg: \(error.localizedDescription)")
        }
    }

    func switchLocationOn() {
        //switchArroundMe.isOn = true
        lblSearchTitle.text = "Within 80 Kilometers".localized()
        btnSearchCriteria.setImage(#imageLiteral(resourceName: "btn_refresh_location"), for: .normal)
        list()
    }
    
    func switchLocationOff() {
        locationManager.stopUpdatingLocation()
        //switchArroundMe.isOn = false
        self.selectedCriteria = Search.DefaultCriterias[0]
        if Localize.currentLanguage() == "en" {
        self.lblSearchTitle.text = selectedCriteria.title
        } else {
            self.lblSearchTitle.text = selectedCriteria.arTitle
        }
        self.btnSearchCriteria.setImage(#imageLiteral(resourceName: "btn_search_filter"), for: .normal)
        list()
    }

    @IBAction func stateChange(_ sender: UISwitch) {
        //print(sender.isOn)
        if sender.isOn {
            self.btnName = "Set"
            self.coveragePopoverForSet = true
            self.performSegue(withIdentifier: "toSetCoverage", sender: self)
        } else {
            switchOff()
        }
    }
    
    func switchOff() {
       // self.switchCoverage.isOn = false
        self.selectedInsurance = nil
        self.selectedDepartment = nil
        self.btnCoverage.setTitle("", for: .normal)
        self.btnCoverage.isHidden = true
        self.lblWarning.text = ""
        list()
    }
    
    func switchOn() {
        //self.switchCoverage.isOn = true
        self.btnCoverage.isHidden = false
        self.btnCoverage.setTitle(self.selectedInsurance?.name, for: .normal)
        lblWarning.text = "It may take some time".localized()
        list()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchCriteria" {
            let vc = segue.destination as! SearchCriteriaVC
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:150)
            vc.popoverPresentationController?.delegate = self
            vc.selection = self.selectedCriteria
        } else if segue.identifier == "toProviderProfile" {
            let nvc = segue.destination as! UINavigationController
            let vc = nvc.topViewController as! ProviderProfileVC
            nvc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height/2)
            nvc.popoverPresentationController?.delegate = self
            vc.selection = self.selectedProvider?.id
            vc.title = self.selectedProvider?.name
            vc.coverageRetryDelegate = requireRetryDelegate ? self : nil
        } else if segue.identifier == "toSetCoverage" {
            let nvc = segue.destination as! UINavigationController
            let vc = nvc.topViewController as! CheckInsuranceVC
            nvc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height/2)
            nvc.popoverPresentationController?.delegate = self
            vc.setCoverageDelegate = self
            vc.btnName = self.btnName!
        } else if segue.identifier == "toSearch" {
            let nvc = segue.destination as! UINavigationController
            let vc = nvc.topViewController as! SearchSuggestionVC
            nvc.preferredContentSize = CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height/2)
            nvc.popoverPresentationController?.delegate = self
            vc.isFromCoverage = true
        }
    }

    @IBAction func criteriaAction(_ sender: UIButton) {
        if self.switchArroundMe.isOn {
            findLocation()
        } else {
            self.performSegue(withIdentifier: "toSearchCriteria", sender: self)
        }
    }
    
    @IBAction func changeCoverage(_ sender: UIButton) {
        Insurances.selectedInsurance = self.selectedInsurance
        Insurances.selectedDepartment = self.selectedDepartment!
        self.btnName = "Reset"
        self.performSegue(withIdentifier: "toSetCoverage", sender: self)
    }
    
    @IBAction func more(_ sender: UIButton) {
        if self.activityIndicator.isHidden {
            btnMore.isHidden = true
            more()
        }
    }
    
    func set(selectedInsurance: Insurances.Member, selectedDepartment: Insurances.Department) {
        self.selectedInsurance = selectedInsurance
        self.selectedDepartment = selectedDepartment
        self.coveragePopoverForSet = false
        switchOn()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset) > 100  {
            return
        }
        if nextPage == nil {
            return
        }
        btnMore.isHidden = false
    }
    
    func showOptions() {
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // 2
        let viewAction = UIAlertAction(title: "View", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toProviderProfile", sender: self)
        })
        
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.requireRetryDelegate = true
            Insurances.selectedInsurance = self.selectedInsurance
            Insurances.selectedDepartment = self.selectedDepartment!
            self.performSegue(withIdentifier: "toProviderProfile", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // 4
        optionMenu.addAction(viewAction)
        optionMenu.addAction(retryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }

    func retried() {
        if let path = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: path) {
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "img_eligible_text"))
            self.founds?[path.row].coverage = "ELIGIBLE"
        }
    }
    
    func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        //print("popover dismiss")
        if self.coveragePopoverForSet {
            self.coveragePopoverForSet = false
            self.switchCoverage.setOn(false, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
