//
//  SelectDepartmentVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/20/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class SelectDepartmentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var departments : [Insurances.Department] = Insurances.testDepartments()
    var selection: Insurances.Department?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = self.title?.localized()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if Localize.currentLanguage() == "en" {
            cell.textLabel?.text = self.departments[indexPath.row].name
        } else {
            cell.textLabel?.text = self.departments[indexPath.row].nameAr
        }
        if highlight(cell: self.departments[indexPath.row]) {
            cell.textLabel?.textColor = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1.0)
        } else {
            cell.textLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selection = self.departments[indexPath.row]
        Insurances.selectedDepartment = self.selection!
        self.performSegue(withIdentifier: "selected", sender: self)
    }
    
    func highlight(cell: Insurances.Department)-> Bool {
        if cell.code == self.selection?.code {
            return true
        }
        return false
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
