//
//  ProviderProfileVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/20/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import MapKit

class ProviderProfileVC: UIViewController {

    
    var insuranceUpdateDelegate: InsuranceUpdateDelegate?
    var coverageRetryDelegate: CoverageRetryDelegate?
    var selection: String!
    var phone: URL?
    var lat: Double?
    var lng: Double?
    var checkPage: String?
    var inquiryPage: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnNavigate: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnNavigate.alpha = 0.3
        btnNavigate.isEnabled = false
        
        btnCall.alpha = 0.3
        btnCall.isEnabled = false
        
        if let _ = coverageRetryDelegate {
            self.performSegue(withIdentifier: "toCheckCoverage", sender: self)
        } else {
            loadDetails()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "statusbar_green"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func loadDetails(){
        details()
    }
    
    func details() {
        
        if let profile = Profile(id: self.selection) {
            /* activity indicator */
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            profile.details(completionHandler: { (result, error) in
                /* if user navigates */
                if self.navigationController?.topViewController != self {
                    return
                }
                /* stop activity indicator */
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                if error == nil {
                    self.present(profile: result)
                    self.checkPage = result?.links?.getURL(oneRel: rel.checkEligibility)
                    self.inquiryPage = result?.links?.getURL(oneRel: rel.inquireApproval)
                } else {
                    //let err = NSURLErrorDomain.caseInsensitiveCompare((error?.domain)!) == NSComparisonResult.OrderedSame ? "Healthcover requires a working internet connection. Please, check your internet connectivity.": error?.localizedDescription
                    let err = error?.localizedDescription
                    let alert = UIAlertController(title: err, message: "", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            
        } else {
            let alert = UIAlertController(title: "Sorry, profile couldn't be loaded. Please, try later.", message: "", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func present(profile: Profile.Result?) {
        let detail = profile?.detail
        //self.hospitalName.text = detail?.name
        
        /* photo */
        /*if let photo = detail?.photo {
            self.hospitalPhoto!.image = photo
            
            let multiplier = CGFloat(0.35)
            let newConstraint = NSLayoutConstraint(
                item: lctPhoto.firstItem,
                attribute: lctPhoto.firstAttribute,
                relatedBy: lctPhoto.relation,
                toItem: lctPhoto.secondItem,
                attribute: lctPhoto.secondAttribute,
                multiplier: multiplier,
                constant: lctPhoto.constant)
            
            newConstraint.priority = lctPhoto.priority
            
            NSLayoutConstraint.deactivateConstraints([lctPhoto])
            NSLayoutConstraint.activateConstraints([newConstraint])
            
            UIView.animateWithDuration(0.5) {
                self.view.layoutIfNeeded()
            }
            
        }
        */
        
        /* address */
        /*var address = ""
        if let city = detail?.city {
            address += city + ","
        }
        if let street = detail?.street {
            address += street
        }
        self.hospAddressText.text = address*/
        
        /* url */
        /*if (detail?.url ?? "").isEmpty {
            self.disable(self.visitSiteBtn, icon: self.urlPicOutlet, disabledImage: self.disabledWebImage!, label: self.lblWeb)
        } else if let url = detail?.url {
            self.lblWeb.text = url
        }*/
        
        /* call */
        if (detail?.phone ?? "").isEmpty {
           btnCall.alpha = 0.2
        } else if (detail?.phone) != nil {
            //print((detail?.phone)!)
             if let url = URL(string: "tel://\((detail?.phone)!)") {
                self.phone = url
                btnCall.alpha = 1
                btnCall.isEnabled = true
             } else {
                btnCall.alpha = 0.2
            }
        }
        
        /* navigation */
        if let _lat = detail?.lat, let _lng = detail?.lng {
            if _lat==0 && _lng==0 {
                btnNavigate.alpha = 0.2
                btnNavigate.isEnabled = false
            } else {
            self.lat = _lat
            self.lng = _lng
            map(lat: lat!, lng: lng!)
            btnNavigate.alpha = 1.0
            btnNavigate.isEnabled = true
            }
        } else {
            btnNavigate.alpha = 0.2
            btnNavigate.isEnabled = false
        }
        
        /* timing */
        /*if let open = detail?.isOpen {
            hospitalStatus.text = open ? "OPEN" : ""
            timingStatusView.hidden = open ? false : true
        }
        self.times = detail?.timings
        self.timingsTableView?.reloadData()
        
        /* departments */
        self.departments = detail?.departments*/
    }
    
    func map(lat: Double, lng: Double) {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func call(_ sender: UIButton) {
        if let url = phone {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        let weblink = NSString(format: "http://maps.google.com/maps?z=12&t=m&q=loc:%f+%f", lat!, lng!)
        //print(weblink)
        let weburl = NSURL(string: weblink as String)!
        if UIApplication.shared.canOpenURL(weburl as URL){
            UIApplication.shared.open(weburl as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCheckCoverage" {
            let vc = segue.destination as! CheckInsuranceVC
            vc.insuranceUpdateDelegate = self.insuranceUpdateDelegate
            vc.selectedProvider = self.selection
            vc.url = "\(URLs.PROVIDERS)/\(self.selection!)/check"
            vc.coverageRetryDelegate = self.coverageRetryDelegate
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
