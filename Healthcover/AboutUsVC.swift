//
//  AboutUsVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/15/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class AboutUsVC: UIViewController {
    
    @IBOutlet weak var btnWaseel: UIButton!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnWaseel.setTitle("Waseel ASP Ltd.".localized(), for: .normal)
        lbl1.text = lbl1.text?.localized()
        lbl2.text = lbl2.text?.localized()
        lbl3.text = lbl3.text?.localized()
        btnClose.setTitle(btnClose.title(for: .normal)?.localized(), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func visitSite(_ sender: UIButton) {
        if let url = URL(string: "https://www.waseel.com/" as String) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
