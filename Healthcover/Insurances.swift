//
//  Insurances.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/16/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class Insurances {
    
    static var selectedInsurance: Insurances.Member?
    static var selectedDepartment: Insurances.Department = Insurances.Department(name: "General Practice", nameAr: "طبيب عام", code: "10")
    
    class Policy {
        var id: String!
        var companyNameEn: String!
        var companyNameAr: String!
        var companyCode: String!
        var holderName: String?
        var startDate: String?
        var endDate: String?
        var policyType: String?
        var shareAmount: String?
        var shareType: String?
        var members: [Member]?
        
        required init(id: String, companyNameEn: String, companyNameAr: String, companyCode: String, members: [Member]) {
            self.id = id
            self.companyNameEn = companyNameEn
            self.companyNameAr = companyNameAr
            self.companyCode = companyCode
            self.members = members
        }
        
        required init(policyNo: String, cardNo: String, companyNameEn: String, companyNameAr: String, companyCode: String, outcome: JSON) {
            self.id = policyNo
            self.companyNameEn = companyNameEn
            self.companyNameAr = companyNameAr
            self.companyCode = companyCode
            self.holderName = (outcome["policy"]["policyHolder"]).string
            self.policyType = (outcome["policy"]["policyType"]).string
            self.startDate = (outcome["policy"]["startDate"]).string
            self.endDate = (outcome["policy"]["policyType"]).string
            self.shareAmount = (outcome["share"]["amount"]).string
            self.shareType = (outcome["share"]["type"]).string
            members = [Insurances.Member(id: cardNo, name: outcome["member"]["name"].stringValue, relationEn: outcome["member"]["memberType"].stringValue, relationAr: "", policyNo: policyNo, companyCode: companyCode, gender: outcome["member"]["gender"].stringValue, maritalStatus: outcome["member"]["maritalStatus"].stringValue, memberClass: outcome["member"]["memberClass"].stringValue, dob: outcome["member"]["dob"].stringValue, priority: 1)]
        }
    }
    
    class Member {
        var id: String!
        var policyNo: String!
        var companyCode: String!
        var name: String?
        var relationEn: String?
        var relationAr: String?
        var gender: String?
        var maritalStatus: String?
        var memberClass: String?
        var dob: String?
        var priority: Int
        
        required init() {
            id = ""
            policyNo = ""
            priority = -2
        }
        
        
         required init(id: String, name: String?, relationEn: String?, relationAr: String?, policyNo: String?, companyCode: String?,
                       gender: String?, maritalStatus: String?, memberClass: String?, dob: String?, priority: Int) {
            self.id = id
            self.name = name
            self.relationEn = relationEn
            self.relationAr = relationAr
            self.policyNo = policyNo
            self.companyCode = companyCode
            self.gender = gender
            self.maritalStatus = maritalStatus
            self.memberClass = memberClass
            self.dob = dob
            self.priority = priority
        }
    }
    
    class Department {
        let name: String
        let nameAr: String
        let code: String
        
        required init(name: String, nameAr: String, code: String) {
            self.name = name
            self.nameAr = nameAr
            self.code = code
        }
    }
    
    static func testPolicy()-> Policy {
        return Policy(id: "12897-kjnhjkh786", companyNameEn: "Tawuniya", companyNameAr: "", companyCode: "102", members: [Insurances.Member(id: "002265390407002", name: "Saadi Tayyab", relationEn: "Boy", relationAr: "", policyNo: "12897-kjnhjkh786", companyCode: "102", gender: "", maritalStatus: "", memberClass: "", dob: "", priority: 4), Insurances.Member(id: "002265390407001", name: "Muhammad Tayyab", relationEn: "Primary", relationAr: "", policyNo: "12897-kjnhjkh786", companyCode: "102", gender: "", maritalStatus: "", memberClass: "", dob: "", priority: 1)])
    }
    
    static func testDepartments()-> [Department] {
        let depts: [Department]  = [Department(name: "General Practice", nameAr: "طبيب عام", code: "10"),
                                    Department(name: "General Surgery", nameAr: "الجراحة العامة", code: "11"),
                                    Department(name: "Allergy/Immunology", nameAr: "الحساسية / المناعة", code: "1"), Department(name: "Ear Nose Throat (ENT)", nameAr: "الانف والاذن والحنجرة", code: "7"),
                                    Department(name: "Paediatrics", nameAr: "طب الأطفال", code: "28"), Department(name: "Maternity", nameAr: "أمومة", code: "54"),
                                    Department(name: "Gynecology", nameAr: "طب النساء", code: "13"), Department(name: "Dental", nameAr: "الأسنان", code: "4"), Department(name: "Cardiology", nameAr: "طب القلب", code: "2"),
                                    Department(name: "Orthopedic", nameAr: "العظام", code: "27"), Department(name: "Urology", nameAr: "المسالك البولية", code: "31"),
                                    Department(name: "Opthalmic", nameAr: "بصريات", code: "25"),
                                    Department(name: "Dermatology", nameAr: "الجلدية", code: "5"),
                                    Department(name: "Internal Medicine", nameAr: "الطب الباطني", code: "17"),
                                    Department(name: "Physiotherapy", nameAr: "العلاج الطبيعي", code: "69")]
        return depts
    }

    static func check(cardNo: String, policyNo: String, payerNameEn: String, payerNameAr: String, payerCode: String, completion: @escaping (Policy?, NSError?)->Void) {
        let parameters: Parameters = [
            "card": [
                "no": cardNo,
                "policy": policyNo,
                "payer": payerCode
            ],
            "payload": [
                "department": "10"
            ]
        ]
        AF.request(URLs.CARD_CHECK, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response -> Void in
            switch response.result {
            case .success(let data) :
                let json = JSON(data)
                //print(json)
                outcome(json: json, completionHandler: {result, error in
                    if error == nil {
                        let policy = Policy(policyNo: policyNo, cardNo: cardNo, companyNameEn: payerNameEn, companyNameAr: payerNameAr, companyCode: payerCode, outcome: json)
                        completion(policy, nil)
                    } else {
                        completion(nil, error)
                    }
                })
            case.failure(let error):
                completion(nil, error as NSError?)
            }
            
        }
    }
    
    static func details(providerId: String, cardNo: String, policyNo: String, departmentCode: String, payerCode: String, completion: @escaping (Policy?, NSError?)->Void) {
        let parameters: Parameters = [
            "card": [
                "no": cardNo,
                "policy": policyNo,
                "payer": payerCode
            ],
            "payload": [
                "department": departmentCode
            ]
        ]
        AF.request("\(URLs.PROVIDERS)/\(providerId)/check", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response -> Void in
            switch response.result {
            case .success(let data) :
                let json = JSON(data)
                outcome(json: json, completionHandler: {result, error in
                    if error == nil {
                        let policy = Policy(policyNo: policyNo, cardNo: cardNo, companyNameEn: "", companyNameAr: "", companyCode: payerCode, outcome: json)
                        completion(policy, nil)
                    } else {
                        completion(nil, error)
                    }
                })
            case.failure(let error):
                completion(nil, error as NSError?)
            }
            
        }
    }

    
    static func eligibility(url: String!, cardNo: String, policyNo: String, payerCode: String, department: String, completion: @escaping (String?, NSError?)->Void) {
        //print(url)
        let parameters: Parameters = [
            "card": [
                "no": cardNo,
                "policy": policyNo,
                "payer": payerCode
            ],
            "payload": [
                "department": department
            ]
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response -> Void in
            switch response.result {
            case .success(let data) :
                let json = JSON(data)
                outcome(json: json, completionHandler: {result, error in
                    if error == nil {
                        //let policy = Policy(policyNo: policyNo, cardNo: cardNo, companyNameEn: "", companyNameAr: "", companyCode: payerCode, outcome: json)
                        completion(json["status"].stringValue, nil)
                    } else {
                        completion(nil, error)
                    }
                })
            case.failure(let error):
                completion(nil, error as NSError?)
            }
        }
    }

    
    static func outcome(json: JSON, completionHandler: (Any?, NSError?) -> Void) {
        if json["outcome"].stringValue.caseInsensitiveCompare("success") == ComparisonResult.orderedSame {
            if json["status"].stringValue.caseInsensitiveCompare("INVALID") == ComparisonResult.orderedSame {
                completionHandler(nil, NSError(domain: "Healthcover", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid insurance information.\nPlease try again."]))
            } else {
            completionHandler("success", nil)
            }
        } else {
            completionHandler(nil, NSError(domain: "Healthcover", code: 404, userInfo: [
                NSLocalizedDescriptionKey: json["message"].stringValue]))
        }
    }
    
    static func validate(value: String?)->String?  {
        if let v = value, !v.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return v
        }
        return nil
    }
    
    static func insert(data: Policy?, context: NSManagedObjectContext)->Bool {
        let policy = Insured_Policy(context: context)
        policy.company_code = data?.companyCode
        policy.company_name_en = data?.companyNameEn
        policy.company_name_ar = data?.companyNameAr
        policy.end_date = validate(value: data?.endDate)
        policy.policy_holder = validate(value: data?.holderName)
        policy.policy_no = validate(value: data?.id)
        policy.policy_type = validate(value: data?.policyType)
        policy.start_date = validate(value: data?.startDate)
        policy.share_amount = validate(value: data?.shareAmount)
        policy.share_type = validate(value: data?.shareType)
        
        // persist policy
        do {
            try context.save()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    static func insert(data: Member?, context: NSManagedObjectContext)->Bool {
        let member = Insured_Member(context: context)
        member.company_code = data?.companyCode
        member.dob = validate(value: data?.dob)
        member.gender = validate(value: data?.gender)
        member.marital_status_en = validate(value: data?.maritalStatus)
        member.member_no = data?.id
        member.member_type_en = validate(value: data?.relationEn)
        member.name = validate(value: data?.name)
        member.policy_no = validate(value: data?.policyNo)
        if let type = member.member_type_en {
            if "PRINCIPAL".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                member.priority = 1
            } else if "WIFE".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                member.priority = 2
            } else if "DEPENDENT".caseInsensitiveCompare(type) == ComparisonResult.orderedSame {
                member.priority = 3
            } else {
                member.priority = 4
            }
        } else {
            member.priority = 4
        }
        
        // persist member
        do {
            try context.save()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    static func findMember(policyNo: String, cardNo: String, payerCode: String, context: NSManagedObjectContext)-> Insured_Member? {
        let request: NSFetchRequest<Insured_Member> = Insured_Member.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND member_no == %@ AND company_code = %@", policyNo, cardNo, payerCode)
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return searchResults[0]
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func list(context: NSManagedObjectContext)-> [Insurances.Policy] {
        var policies:Array = Array<Insurances.Policy>()
        if let policyData = Insurances.listPolicies(context: context) {
            for data: Insured_Policy in policyData {
                let policy = Insurances.Policy(id: data.policy_no!, companyNameEn: data.company_name_en!, companyNameAr: data.company_name_ar!, companyCode: data.company_code!, members: self.list(policyNo: data.policy_no!, payerCode: data.company_code!, context: context))
                
                policies.append(policy)
            }
        }
        return policies
    }
    
    static func list(policyNo: String, payerCode: String, context: NSManagedObjectContext)-> [Insurances.Member] {
        var members: Array = Array<Insurances.Member>()
        if let memberData = Insurances.listMembers(policyNo: policyNo, payerCode: payerCode, context: context) {
            for data: Insured_Member in memberData {
                let member = Insurances.Member(id: data.member_no!, name: data.name, relationEn: data.member_type_en, relationAr: data.member_type_ar, policyNo: data.policy_no!, companyCode: data.company_code, gender: data.gender, maritalStatus: data.marital_status_en, memberClass: "", dob: data.dob, priority: Int(data.priority))
                members.append(member)
            }
        }
        return members
    }

    
    static func listPolicies(context: NSManagedObjectContext)-> [Insured_Policy]? {
        let request: NSFetchRequest<Insured_Policy> = Insured_Policy.fetchRequest()
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return searchResults
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func listMembers(policyNo: String, payerCode: String, context: NSManagedObjectContext)-> [Insured_Member]? {
        let request: NSFetchRequest<Insured_Member> = Insured_Member.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo, payerCode)
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return searchResults
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func listAllMembers(context: NSManagedObjectContext)-> [Insured_Member]? {
        let request: NSFetchRequest<Insured_Member> = Insured_Member.fetchRequest()
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return searchResults
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func findPolicy(policyNo: String, payerCode: String, context: NSManagedObjectContext)-> Insured_Policy? {
        let request: NSFetchRequest<Insured_Policy> = Insured_Policy.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo,payerCode)
        do {
            let searchResults = try context.fetch(request)
            if searchResults.count > 0 {
                return searchResults[0]
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func updatePolicy(context: NSManagedObjectContext, policyNo: String, payerCode: String, policy: Policy) -> Insured_Policy? {
        let request: NSFetchRequest<Insured_Policy> = Insured_Policy.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo, payerCode)
        do {
            let res = try context.fetch(request)
            if res.count > 0 {
                if let share_amount = policy.shareAmount, !share_amount.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    res[0].share_amount = share_amount
                }
                if let share_type = policy.shareType, !share_type.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    res[0].share_type = share_type
                }
                try context.save()
                return res[0]
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func updatePolicyDetail(context: NSManagedObjectContext, policyNo: String, memberId: String, departmentCode: String, payerCode: String, results: [NearBySearchResult.Result]?) {
        if results == nil {
            return
        }
        var found: NearBySearchResult.Result?
        for result in results! {
            if let coverage = result.coverage, coverage.caseInsensitiveCompare("ELIGIBLE") == ComparisonResult.orderedSame {
                found = result
                break
            }
        }
        if let _ = found {
            let request: NSFetchRequest<Insured_Provider> = Insured_Provider.fetchRequest()
            request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo,payerCode)
            do {
                let res = try context.fetch(request)
                if res.count > 0 {
                    res[0].id = found?.id
                    res[0].member_id = memberId
                    res[0].department_code = departmentCode
                    try context.save()
                } else {
                    let provider = Insured_Provider(context: context)
                    provider.id = found?.id!
                    provider.policy_no = policyNo
                    provider.company_code = payerCode
                    try context.save()
                }
            } catch {
                print("Error with request: \(error)")
            }
        }
    }
    
    static func canDetailsFetch(context: NSManagedObjectContext, policyNo: String, payerCode: String) -> Insured_Provider? {
        let request: NSFetchRequest<Insured_Provider> = Insured_Provider.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo,payerCode)
        do {
            let res = try context.fetch(request)
            if res.count > 0 {
                return res[0]
            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    
    static func deletePolicy(context: NSManagedObjectContext, policyNo: String, payerCode: String) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //print(urls[urls.count-1] as URL)
        deleteMembers(context: context, policyNo: policyNo, payerCode: payerCode)
        deleteProvider(context: context, policyNo: policyNo, payerCode: payerCode)
        let request: NSFetchRequest<Insured_Policy> = Insured_Policy.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo, payerCode)
        do {
            let results = try context.fetch(request)
            for result in results {
                context.delete(result)
            }
            try context.save()
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    static func deleteMembers(context: NSManagedObjectContext, policyNo: String, payerCode: String) {
        let request: NSFetchRequest<Insured_Member> = Insured_Member.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo, payerCode)
        do {
            let results = try context.fetch(request)
            for result in results {
                context.delete(result)
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    static func deleteProvider(context: NSManagedObjectContext, policyNo: String, payerCode: String) {
        let request: NSFetchRequest<Insured_Provider> = Insured_Provider.fetchRequest()
        request.predicate = NSPredicate(format: "policy_no == %@ AND company_code = %@", policyNo, payerCode)
        do {
            let results = try context.fetch(request)
            for result in results {
                context.delete(result)
            }
        } catch {
            print("Error with request: \(error)")
        }
    }


}
