//
//  MenuVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 12/12/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class MenuVC: UITableViewController {

    @IBOutlet weak var lang: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lang.text = "English".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if Localize.currentLanguage() == "en" {
                Localize.setCurrentLanguage("ar")
            } else {
                Localize.setCurrentLanguage("en")
            }
            tableView.deselectRow(at: indexPath, animated: false)
            self.performSegue(withIdentifier: "toHome", sender: self)
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
