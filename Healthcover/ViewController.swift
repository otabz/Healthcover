//
//  ViewController.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/1/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class ViewController: UIViewController {

    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnAboutUs: UIButton!
    @IBOutlet weak var lblHospitals: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.revealViewController() != nil {
            btnMenu.target = self.revealViewController()
            btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.lblDesc.text = "Find hospitals/clinics covered under\nyour health insurance.".localized()
        self.btnAboutUs.setTitle("About us".localized(), for: .normal)
        self.lblHospitals.text = self.lblHospitals.text?.localized()
        
        if  Localize.currentLanguage() == "ar" {
            self.lblHospitals.font = UIFont(name: "AvenirNextCondensed-Regular", size: 19.0)
        } else {
            self.lblHospitals.font = UIFont(name: "AvenirNextCondensed-Medium", size: 19.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func `continue`(_ sender: UIButton) {
        /*let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let prefs = UserDefaults.standard
        prefs.set(true, forKey: "userAgreedToContinue")
        UserDefaults.standard.synchronize()
        let unlockedVC = storyBoard.instantiateViewController(withIdentifier: "WelcomePage") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = unlockedVC
            UIApplication.shared.keyWindow?.makeKeyAndVisible()*/
    }

}

