//
//  SearchCriteriaVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/17/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class SearchCriteriaVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selection: Search.SearchCiteria?
    lazy var criterias: [Search.SearchCiteria] = {
        if Search.SyncedCriterias.isEmpty {
            return Search.DefaultCriterias
        }
        return Search.SyncedCriterias
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return criterias.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if Localize.currentLanguage() == "en" {
            cell.textLabel?.text = criterias[indexPath.row].title
            cell.textLabel?.font = UIFont(name: "AvenirNextCondensed-Medium", size: 20.0)
        } else {
            cell.textLabel?.text = criterias[indexPath.row].arTitle
            cell.textLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)
        }
        if criterias[indexPath.row].id == -1 {
            //cell.detailTextLabel?.text = criterias[indexPath.row].subTitle
        } else {
            //    cell.detailTextLabel?.text = ""
        }
        cell.tag = criterias[indexPath.row].id
        if cell.tag == selection?.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selection = criterias[indexPath.row]
        self.performSegue(withIdentifier: "exitForCoverage", sender: self)
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
