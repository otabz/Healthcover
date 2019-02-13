//
//  Payers.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/2/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation

class Payers {
    
    static func list() -> [Payer] {
        var payers: [Payer]?
        if SyncedPayers.isEmpty || SyncedPayers.count <= 5 {
            payers =  DefaultPayers
        } else {
            payers = SyncedPayers
        }
        let sortedPayers = payers!.sorted {
            $0.portalCode < $1.portalCode
        }
        return sortedPayers
    }
    
    static var DefaultPayers: [Payer] = {
        return [
            Payer(enName: "Tawuniya", arName: "التعاونية", portalCode: "102"),
            Payer(enName: "MedGulf", arName: "شركة المتوسط والخليج للتأمين وإعادة التأمين التعاوني", portalCode: "300"),
            Payer(enName: "Malath", arName: "ملاذ للتامين", portalCode: "201"),
            Payer(enName: "AXA", arName: "اكسا للتأمين", portalCode: "204"),
            Payer(enName: "SAICO", arName: "الشركة العربية السعودية للتأمين التعاوني", portalCode: "205"),
            Payer(enName: "Rajhi", arName: "تكافل الراجحي", portalCode: "207"),
            Payer(enName: "SAGR", arName: "شركة الصقر للتأمين التعاوني", portalCode: "208"),
            Payer(enName: "Walaa", arName: "الشركة السعودية المتحدة للتأمين التعاوني", portalCode: "209"),
            Payer(enName: "ArabianShield", arName: "الدرع العربي للتأمين", portalCode: "301"),
            Payer(enName: "ASF", arName: "شركة أليانز السعودي الفرنسي للتأمين التعاوني", portalCode: "302")]
    }()
    
    static func update(payers: [Network]?) {
        if let _payers = payers {
            SyncedPayers.removeAll()
            for network: Network in _payers {
                if let payerId = network.networkID, let payerName = network.networkName {
                    let payer = Payer(enName: payerName.components(separatedBy: "|")[0], arName: payerName.components(separatedBy: "|")[1], portalCode: payerId)
                    SyncedPayers.append(payer)
                }
            }
        }
    }
    
    static var SyncedPayers = [Payer]()
}

class Payer {
    let enName: String
    let arName: String
    let portalCode: String
    
    init(enName: String, arName: String, portalCode: String) {
        self.enName = enName
        self.arName = arName
        self.portalCode = portalCode
    }
}
