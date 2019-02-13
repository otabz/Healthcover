//
//  SearchSuggestionVC.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
protocol FindDelegate: class {
    func find()
}
class SearchSuggestionVC: UIViewController {


    @IBOutlet weak var txtSearch: AutoCompleteTextField!
    fileprivate var dataTask:URLSessionDataTask?
    fileprivate let baseURLString = URLs.TEXT_SEARCH
    
    var isFromCoverage = false
    var findDelegate: FindDelegate?
    var departments : [Insurances.Department] = Insurances.testDepartments()
    var insuranceUpdateDelegate: InsuranceUpdateDelegate?
    var suggestions: [NearBySearchResult.Result]?
    var nextPage: String?
    var selection: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "statusbar_green"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        /*self.txtSearch.delegate = self*/
        
        configureTextField()
        handleTextFieldInterfaces()
        
    }
    
    fileprivate func configureTextField(){
        txtSearch.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        txtSearch.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        txtSearch.autoCompleteCellHeight = 35.0
        txtSearch.maximumAutoCompleteCount = 40
        txtSearch.hidesWhenSelected = true
        txtSearch.hidesWhenEmpty = true
        txtSearch.enableAttributedText = true
        var attributes = [NSAttributedString.Key:Any]()
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
        attributes[NSAttributedString.Key.font] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        txtSearch.autoCompleteAttributes = attributes
    }
    
    fileprivate func handleTextFieldInterfaces(){
        txtSearch.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        txtSearch.onSelect = {[weak self] text, indexpath in
            self?.selection = text
            self?.performSegue(withIdentifier: "toProviderProfile", sender: self)
        }
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?q=\(keyword)"
        //print(urlString)
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                            let json = JSON(result)
                            if let status = result["outcome"] as? String{
                                if status == "success"{
                                     let results = NameSearchResult.results(json: json).toNearSearchResult() //{
                                   // if let predictions = result["predictions"] as? NSArray{
                                   //     var locations = [String]()
                                   //     for dict in predictions as! [NSDictionary]{
                                   //         locations.append(dict["description"] as! String)
                                   //     }
                                    var providers = [Node]()
                                    for p in results.results! {
                                        providers.append(Node(id: p.id!, name: p.name!))
                                    }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.txtSearch.autoCompleteStrings = providers
                                        })
                                        return
                                    //}
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.txtSearch.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.txtSearch.becomeFirstResponder()
    }

    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProviderProfile" {
            let vc = segue.destination as! ProviderProfileVC
            vc.insuranceUpdateDelegate = self.insuranceUpdateDelegate
            vc.title = txtSearch.text
            vc.selection = self.selection
        }
    }
    
    @IBAction func find(_ sender: UIButton) {
      //self.performSegue(withIdentifier: "exitForFind", sender: self)
        self.dismiss(animated: true, completion: {
            self.findDelegate?.find()
        })
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
