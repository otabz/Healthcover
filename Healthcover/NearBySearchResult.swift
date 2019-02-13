//
//  NearBySearchResult.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 12/3/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import UIKit


class NearBySearchResult: NSObject {
    
    class SearchResult {
        var links: Links?
        var results: [NearBySearchResult.Result]?
        var networks: [Network]?
        var categories: [Category]?
        var cities: [City]?
        
        required init() {
            
        }
        
        required init(json: JSON) {
            //print(json)
            /* links */
            self.links = Links(json: json["links"])
            
            /* results */
            var found:Array = Array<NearBySearchResult.Result>()
            let results = json["results"]
            //print(results)
            for each in results {
                //print(each)
                let node = Result(json: each.1)
                found.append(node)
            }
            self.results = found
            
            /* networks */
            var networks:Array = Array<Network>()
            let _networks = json["networks"]
            for each in _networks {
                let node = Network(networkID: each.0, networkName: each.1.stringValue)
                networks.append(node)
            }
            self.networks = networks
            
            /* categories */
            var categories:Array = Array<Category>()
            let _categories = json["categories"]
            for each in _categories {
                let node = Category(categoryID: each.0, categoryName: each.1.stringValue)
                categories.append(node)
            }
            self.categories = categories
            
            /* cities */
            var cities:Array = Array<City>()
            let _cities = json["cities"]
            for each in _cities {
                let node = City(cityID: each.0, cityName: each.1.stringValue.components(separatedBy: "|")[0], cityNameAr: each.1.stringValue.components(separatedBy: "|")[1])
                cities.append(node)
            }
            self.cities = cities
        }
    }
    
    class Result {
        
        var name: String?
        var nameAr: String?
        var id: String?
        var distance:Float?
        var street: String?
        var city: String?
        var country: String?
        var timingStatus: Bool?
        var icon :UIImage?
        var lat: String?
        var lng: String?
        var coverage: String?
        
        required init(id: String?, name: String?, nameAr: String?, street: String?, city: String?, country: String?, coverage: String?) {
            self.id = id
            self.name = name
            self.nameAr = nameAr
            self.street = street
            self.city = city
            self.country = country
            self.coverage = coverage
        }
        
        required init(json: JSON) {
            name = json["name"].stringValue
            
            nameAr = json["nameAr"].stringValue
            
            distance = json["distance"].floatValue
            
            id = json["id"].stringValue
            
            city = json["address"]["city"]["name"].stringValue
            
            timingStatus = json["openNow"].boolValue
            
            street = json["address"]["street"].stringValue
            
            country = json["address"]["country"]["name"].stringValue
            
            lat = json["lat"].stringValue
            
            lng = json["lng"].stringValue
            
            coverage = json["coverageResult"].stringValue
            
            if (json["icon"] != nil) {
                icon = self.toUIImage(imageAsBase64String: json["icon"].stringValue)
            }
        }
        func toUIImage (imageAsBase64String: String) -> UIImage {
            
            if let decodedData = NSData(base64Encoded: imageAsBase64String, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                //if let decodedImage = toUIImage(data: (decodedData) as Data) {
                //    return (decodedImage)
                //}
            }
            return UIImage()
        }
    }
    
    internal class func results(json: JSON) ->  NearBySearchResult.SearchResult {
        return SearchResult(json: json)
    }
    
}
