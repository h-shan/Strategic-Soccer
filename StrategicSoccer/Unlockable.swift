//
//  Unlockable.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/17/16.
//  Copyright © 2016 HS. All rights reserved.
//
import UIKit
struct PropertyKey{
    static let flagKey = "unlockedFlags"
    static let coinKey = "numberCoins"
}
class Unlockable: NSObject, NSCoding{
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let FlagURL = DocumentsDirectory.URLByAppendingPathComponent("flags")
    static let CoinURL = DocumentsDirectory.URLByAppendingPathComponent("coins")
    var unlockedFlags: [String] = ["UNITED STATES", "FRANCE", "CHINA", "JAPAN","CANADA","GERMANY", "MEXICO", "AUSTRALIA","SPAIN","ITALY"]
    var numberCoins = 50
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.decodeObjectForKey(PropertyKey.flagKey) == nil{
            aDecoder.encodeObject(unlockedFlags, forKey: PropertyKey.flagKey)
        }else{
            unlockedFlags = aDecoder.decodeObjectForKey(PropertyKey.flagKey) as! [String]
        }
        if aDecoder.decodeObjectForKey(PropertyKey.coinKey) == nil{
            aDecoder.encodeObject(numberCoins, forKey: PropertyKey.coinKey)
        }else{
            numberCoins = aDecoder.decodeObjectForKey(PropertyKey.coinKey) as! Int
        }
    }
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(unlockedFlags, forKey: PropertyKey.flagKey)
        aCoder.encodeObject(numberCoins, forKey: PropertyKey.coinKey)
    }
}
