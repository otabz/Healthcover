//
//  NameSearchResult.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 12/4/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation

class NameSearchResult: NSObject {
    
    class SearchResult {
        var links: Links?
        var results: [NameSearchResult.Result]?
        var networks: [Network]?
        var categories: [Category]?
        var cities: [City]?
        
        required init(json: JSON) {
            /* links */
            self.links = Links(json: json["links"])
            
            /* results */
            var found:Array = Array<NameSearchResult.Result>()
            let results = json["results"]
            
            for sections in results {
                for each in sections.1 {
                    let node = Result(json: each.1)
                    found.append(node)
                }
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
        
        func toNearSearchResult() -> NearBySearchResult.SearchResult {
            let nearBySearchResult = NearBySearchResult.SearchResult()
            if let rs = self.results {
                var nearByResults = Array<NearBySearchResult.Result>()
                for result in rs {
                    let n : NearBySearchResult.Result = NearBySearchResult.Result(id: result.id, name: result.name, nameAr: result.nameAr, street: result.street, city: result.city, country: result.country, coverage: result.coverage)
                    nearByResults.append(n)
                }
                nearBySearchResult.results = nearByResults
            }
            nearBySearchResult.links = self.links
            nearBySearchResult.cities = self.cities
            nearBySearchResult.networks = self.networks
            return nearBySearchResult
        }
    }
    
    class Result {
        
        var name: String?
        var nameAr: String?
        var id: String?
        var street: String?
        var city: String?
        var country: String?
        var coverage: String?
        
        required init(json: JSON) {
            name = json["name"].stringValue
            
            nameAr = json["nameAr"].stringValue
            
            id = json["id"].stringValue
            
            city = json["address"]["city"]["name"].stringValue
            
            street = json["address"]["street"].stringValue
            
            country = json["address"]["country"]["name"].stringValue
            
            coverage = json["coverageResult"].stringValue
            
        }
    }
    
    internal class func results(json: JSON) ->  NameSearchResult.SearchResult {
        return SearchResult(json: json)
    }
    
}
