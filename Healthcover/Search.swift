//
//  Search.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/24/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import Alamofire

class Location {
    var long: Double?
    var lat: Double?
    
    init?(lat: Double?, long: Double?){
        if let x = lat, let y = long {
            self.lat = x
            self.long = y
        } else {
            return nil
        }
    }
}

class Category {
    
    var categoryID: String!
    var categoryName: String!
    
    init(categoryID: String, categoryName: String){
        self.categoryID = categoryID
        self.categoryName = categoryName
    }
    
    init(category: Category){
        self.categoryID = category.categoryID
        self.categoryName = category.categoryName
    }
    
}

class Network {
    
    var networkID: String!
    var networkName: String!
    
    init(networkID: String, networkName: String){
        self.networkID = networkID
        self.networkName = networkName
    }
    
    init(network: Network){
        self.networkID = network.networkID
        self.networkName = network.networkName
    }
    
}

class City {
    var cityID : String!
    var cityName : String!
    var cityNameAr: String!
    
    init(cityID: String, cityName: String, cityNameAr: String){
        self.cityID = cityID
        self.cityName = cityName
        self.cityNameAr = cityNameAr
    }
    
    init(city: City){
        self.cityID = city.cityID
        self.cityName = city.cityName
        self.cityNameAr = city.cityNameAr
    }
}


class Links {
    var linksDictionary = [String:String]()
    
    required init(json: JSON) {
        for eachLink in json {
            //print(eachLink.1["rel"].stringValue)
            linksDictionary[eachLink.1["rel"].stringValue] = eachLink.1["link"].stringValue
        }
        
        //linksDictionary[json["rel"].stringValue] = json["link"].stringValue
    }
    
    required init(path: String!, rel: String!) {
        linksDictionary[rel] = path
    }
    
    func getURL (oneRel: rel) -> String? {
        
        if let url = linksDictionary[oneRel.rawValue] {
            return url
        }
        else {
            return nil
        }
    }
}

enum rel : String {
    case nextPage = "NEXT_PAGE"
    case checkEligibility = "ELIGIBILITY_CHECK"
    case inquireApproval = "APPROVAL_INQUIRY"
    case approvalDetails = "APPROVAL_DETAILS"
    case details = "DETAILS"
}


class Options {
    // for nearby
    var network: Network?
    var category: Category?
    var open = false
    
    // for keyword
    var keyword: String?
    var city: City?
    
    // for coverage
    var coverage = false
    
    typealias BuilderClosure = (Options) -> ()
    
    init(buildClosure: BuilderClosure) {
        buildClosure(self)
    }
}

class Search {
    
    private var filters:[String:AnyObject] = [String:AnyObject]()
    private var parameters:[String:AnyObject] = [String:AnyObject]()
    //var request: Alamofire.DataRequest?
    
    // for near by
    init?(location: Location?, insurance: Insurances.Member?, department: Insurances.Department?, options: Options?){
        //if location == nil {
        //    return nil
        
        //} else {
        //parameters["lat"] = location?.lat as AnyObject?
        //parameters["lng"] = location?.long as AnyObject?
        
        var card : [String:AnyObject] = [String:AnyObject]()
        card["no"] = insurance?.id as AnyObject?
        card["policy"] = insurance?.policyNo as AnyObject?
        card["payer"] = insurance?.companyCode as AnyObject?
        
        var payload : [String:AnyObject] = [String:AnyObject]()
        payload["department"] = department?.code as AnyObject?
        
        parameters["card"] = card as AnyObject?
        parameters["payload"] = payload as AnyObject?
        
        if let _location = location {
            filters["location"] = "\(_location.lat!),\(_location.long!)" as AnyObject?
        }
        
        if let network = options?.network?.networkID {
            filters["network"] = network as AnyObject?
        }
        if let category = options?.category?.categoryID {
            filters["category"] = category as AnyObject?
        }
        if ((options?.open) != nil) {
            if let _open = options?.open {
                filters["open"] = _open ? ("true" as AnyObject?) : ("false" as AnyObject?)
            }
        }
        if (options?.coverage != nil) {
            if let _coverage = options?.coverage {
                filters["coverage"] = _coverage ? ("true" as AnyObject?) : ("false" as AnyObject?)
            }
        }
        //}
        
    }
    
    // for by keyword
    init?(options: Options?, insurance: Insurances.Member?, department: Insurances.Department?) {
        if let city = options?.city?.cityID {
            filters["city"] = city as AnyObject?
        }
        if let q = options?.keyword?.lowercased() {
            filters["q"] = q as AnyObject?
        }
        if (options?.coverage != nil) {
            if let _coverage = options?.coverage {
                filters["coverage"] = _coverage ? ("true" as AnyObject?) : ("false" as AnyObject?)
            }
        }
        /* parameters */
        var card : [String:AnyObject] = [String:AnyObject]()
        card["no"] = insurance?.id as AnyObject?
        card["policy"] = insurance?.policyNo as AnyObject?
        card["payer"] = insurance?.companyCode as AnyObject?
        
        var payload : [String:AnyObject] = [String:AnyObject]()
        payload["department"] = department?.code as AnyObject?
        
        parameters["card"] = card as AnyObject?
        parameters["payload"] = payload as AnyObject?
    }
    
    // for a-z
    init() {
        
    }
    
    func nearBy(nextPage: String, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        let url = URL(string: nextPage)!
        let request = URLRequest(url: url)
        //print(request.url!)
        
        requestNearBy(request: request) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    func nearBy(completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        let url = URL(string: URLs.NEARBY_SEARCH)!
        var request = URLRequest(url: url)//NSMutableURLRequest(url: url)
        let encoding = URLEncoding.default
        do {
            try request = encoding.encode(request as URLRequestConvertible, with: filters)
        } catch {
            //print("error")
        }
        
        requestNearBy(request: request) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    func byKeyword(nextPage: String, method: HTTPMethod, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        let url = URL(string: nextPage)!
        let request = URLRequest(url: url)
        //print(request.url!)
        
        requestByKeyword(request: request, method: method) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    func byKeyword(completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        if let _ = filters["q"] {
            self.keyword(url: URLs.TEXT_SEARCH) { (result, error) -> Void in
                completionHandler(result, error)
            }} else {
            self.list(url: URLs.PROVIDERS) { (result, error) -> Void in
                completionHandler(result, error)
            }
        }
    }
    
    private func keyword(url: String, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)//NSMutableURLRequest(url: url)
        let encoding = URLEncoding.default
        do {
            try request = encoding.encode(request as URLRequestConvertible, with: filters)
            //print(request)
        } catch {
            //print("error")
        }
        
        requestByKeyword(request: request, method: .get) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    private func list(url: String, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)//NSMutableURLRequest(url: url)
        let encoding = URLEncoding.default
        do {
            try request = encoding.encode(request as URLRequestConvertible, with: filters)
            //print(request)
        } catch {
            //print("error")
        }
        
        requestByKeyword(request: request, method: .post) { (result, error) -> Void in
            completionHandler(result, error)
        }
    }
    
    private func requestNearBy(request: URLRequest, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        //print(request)
        AF.request(request.url!, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
       // Alamofire.request(.POST, request.url!, parameters: parameters, encoding: .JSON).responseJSON { response in
            switch response.result {
                
            case .success(let data):
                let json = JSON(data)
                //print(json.description)
                self.outcome(json: json, completionHandler: { (result, error) in
                    if error == nil {
                        //print(json.description)
                        let results = NearBySearchResult.results(json: json)
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
        //self.request = crequest
    }
    
    private func requestByKeyword(request: URLRequest, method: HTTPMethod, completionHandler: @escaping (NearBySearchResult.SearchResult?, NSError?) -> Void) {
        AF.request(request.url!, method: method, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            
            switch response.result {
                
            case .success(let data):
                let json = JSON(data)
                //print(json.description)
                self.outcome(json: json, completionHandler: { (result, error) in
                    if error == nil {
                        //print(json.description)
                        let results = NameSearchResult.results(json: json).toNearSearchResult()
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
        //self.request = crequest
    }
    
    func cancel() {
        //self.request?.cancel();
    }


    func outcome(json: JSON, completionHandler: (AnyObject?, NSError?) -> Void) {
        if json["outcome"].stringValue.caseInsensitiveCompare("success") == ComparisonResult.orderedSame {
            completionHandler("success" as AnyObject?, nil)
        } else {
            completionHandler(nil, NSError(domain: "Healthcover", code: 404, userInfo: [
                NSLocalizedDescriptionKey: json["message"].stringValue]))
        }
    }

    
    class SearchCiteria {
        var option: CriteriaOption
        var id: Int
        var title: String
        var arTitle: String
        
        required init(option: CriteriaOption, id: Int, title: String, arTitle: String) {
            self.option = option
            self.id = id
            self.title = title
            self.arTitle = arTitle
        }
    }
    
    enum CriteriaOption {
        case ByLocation, ByCity
    }
    
    static var DefaultCriterias: [SearchCiteria] = {
        return [/*SearchCiteria(option: CriteriaOption.ByLocation, id: -1, title: "Within 30 Kilometers", subTitle: "Within 30 Kilometers"),*/
            SearchCiteria(option: CriteriaOption.ByLocation, id: 1, title: "Riyadh", arTitle: "الرياض"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 2, title: "Jeddah", arTitle: "جدة"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 3, title: "Dammam", arTitle: "الدمام"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 4, title: "Khobar", arTitle: "الخبر"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 5, title: "Dhahran", arTitle: "الظهران"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 6, title: "Makkah",arTitle: "مكة المكرمة"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 7, title: "Madinah Munawwarah", arTitle: "المدينة المنورة"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 8, title: "Al Taif", arTitle: "الطائف"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 9, title: "Abha", arTitle: "أبها"),
            SearchCiteria(option: CriteriaOption.ByLocation, id: 10, title: "Yanbu", arTitle: "ينبع البحر")]
    }()
    
    static func update(cities: [City]?) {
        if let _cities = cities {
            SyncedCriterias.removeAll()
            for city: City in _cities {
                if let cityId = city.cityID {
                    let criteria = SearchCiteria(option: CriteriaOption.ByLocation, id: Int(cityId)!, title: city.cityName, arTitle: city.cityNameAr)
                    SyncedCriterias.append(criteria)
                }
            }
        }
    }
    
    static var SyncedCriterias = [SearchCiteria]()
    
    class Provider {
        var id: String?
        var nameEn: String?
        var nameAr: String?
        
    }
}
