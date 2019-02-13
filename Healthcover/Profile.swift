//
//  Profile.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 12/6/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation

import Alamofire

import UIKit

class Profile {
    
    class Result: NSObject {
        var links: Links?
        var detail: Detail?
        
        required init(json: JSON) {
            /* links */
            self.links = Links(json: json["links"])
            
            /* details */
            self.detail = Detail(json: json["details"])
        }
    }
    
    class Timing {
        var dayNo: Int?
        var providerNo: String?
        var open: String?
        var close: String?
        var dayName: String?
        var dayShort: String?
        
        init(json: JSON){
            
            self.dayNo = json["day"].int
            self.providerNo = json["provider"].stringValue
            self.open = json["open"].stringValue
            self.close = json["close"].stringValue
            self.dayName = json["localizedDay"].stringValue
            self.dayShort = json["shortLocalizedDay"].stringValue
        }
        
        init(name: String, number: Int){
            self.dayName = name
            self.dayNo = number
        }
    }
    
    class Department {
        var id : String!
        var name: String!
        
        
        init(id: String, name: String){
            self.id = id
            self.name = name
        }
    }
    
    class Detail {
        var id: String?
        var url: String?
        var name: String?
        var photo: UIImage?
        var phone: String?
        var lat:Double?
        var lng:Double?
        var isOpen: Bool?
        var distance :Float?
        var city: String?
        var street: String?
        var country: String?
        var timings = [Timing]()
        var departments = [Department]()
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        required init(json: JSON) {
            self.id = json["id"].stringValue
            self.name = json["name"].stringValue
            self.url = json["url"].stringValue
            self.phone = json["phone"].stringValue
            self.lat = json["lat"].doubleValue
            self.lng = json["lng"].doubleValue
            self.distance = json["distance"].floatValue
            self.isOpen = json["openNow"].boolValue
            self.city = json["address"]["city"]["name"].stringValue
            self.street = json["address"]["street"].stringValue
            self.country = json["address"]["country"]["name"].stringValue
            if (json["photo"] != nil) {
                self.photo = self.toUIImage(imageAsBase64String: json["photo"].stringValue)
            }
            
            /* timings */
            for index in 0...6 {
                let day = Timing(name: days[index], number: index+1)
                self.timings.append(day)
            }
            let times = json["timings"]
            for time in times {
                let _time = Timing(json: time.1)
                if let day = _time.dayNo, day >= 1 && day <= 7 {
                    let d = self.timings[day-1]
                    d.open = _time.open
                    d.close = _time.close
                }
            }
            
            /* departments */
            let departments = json["departments"]
            for department in departments {
                self.departments.append(Department(id: department.0, name: department.1.stringValue))
            }
        }
        
        func toUIImage (imageAsBase64String: String) -> UIImage {
            
            if let decodedData = NSData(base64Encoded: imageAsBase64String, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                //if let decodedImage = toUIImage(imageAsBase64String: (decodedData)) {
                //    return (decodedImage)
                //}
            }
            return UIImage()
        }
        
    }
    
    var id = -1
    
    init?(id: String?) {
        if id == nil {
            return nil
        }
        if let pid:Int = Int(id!) {
            self.id = pid
            return
        }
        return nil
    }
    
    func details(completionHandler: @escaping (Result?, NSError?) -> Void) {
        let url = URL(string: "\(URLs.PROVIDERS)/\(self.id)")!
        var request = URLRequest(url: url)
        let encoding = URLEncoding.default
        do {
            try request = encoding.encode(request as URLRequestConvertible, with: nil)
            //print(request)
        } catch {
            //print("error")
        }
        
        requestProfile(request: request) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    func results(json: JSON) -> Result {
        return Result(json: json)
    }
    
    private func requestProfile(request: URLRequest, completionHandler: @escaping (Result?, NSError?) -> Void) {
        
        AF.request(request.url!, method: .get, encoding: JSONEncoding.default).responseJSON {response in
        //Alamofire.request(.GET, request.URL!, parameters: nil, encoding: .JSON).responseJSON { response in
            
            switch response.result {
                
            case .success(let data):
                let json = JSON(data)
                //print(json.description)
                self.outcome(json: json, completionHandler: { (result, error) in
                    if error == nil {
                        //print("successful -> result")
                        let results = self.results(json: json)
                        completionHandler(results, nil)
                    } else {
                        //print("error -> \(error!.description)")
                        completionHandler(nil, error)
                    }
                })
                
            case .failure(let error):
                //print("error -> \(error.description)")
                completionHandler(nil, error as NSError?)
            }
            
        }
    }
    
    func outcome(json: JSON, completionHandler: (AnyObject?, NSError?) -> Void) {
        if json["outcome"].stringValue.caseInsensitiveCompare("success") == ComparisonResult.orderedSame {
            completionHandler("success" as AnyObject?, nil)
        } else {
            completionHandler(nil, NSError(domain: "Healthcover", code: 404, userInfo: [
                NSLocalizedDescriptionKey: json["message"].stringValue]))
        }
    }
}
