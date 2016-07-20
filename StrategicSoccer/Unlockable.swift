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
    static let statsKey = "statistics"
}
struct Stats{
    static let totalGames = "totalGames"
    static let totalWon = "totalWon"
    static let totalOne = "totalOne"
    static let oneWon = "oneWon"
    static let totalTwo = "totalTwo"
    static let twoWon = "twoWon"
    static let totalThree = "totalThree"
    static let threeWon = "threeWon"
    static let totalFour = "totalFour"
    static let fourWon = "fourWon"
    static let totalFive = "totalFive"
    static let fiveWon = "fiveWon"

}
class Unlockable: NSObject, NSCoding{
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let FlagURL = DocumentsDirectory.URLByAppendingPathComponent("flags")
    static let CoinURL = DocumentsDirectory.URLByAppendingPathComponent("coins")
    static let StatsURl = DocumentsDirectory.URLByAppendingPathComponent("statistics")
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
        if aDecoder.decodeObjectForKey(PropertyKey.statsKey) == nil{
            aDecoder.encodeObject(statistics, forKey: PropertyKey.statsKey)
        }else{
            statistics = aDecoder.decodeObjectForKey(PropertyKey.statsKey) as! [String:Int]
        }
    }
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(unlockedFlags, forKey: PropertyKey.flagKey)
        aCoder.encodeObject(numberCoins, forKey: PropertyKey.coinKey)
        aCoder.encodeObject(statistics, forKey: PropertyKey.statsKey)
    }
}
func saveCoins(){
    NSKeyedArchiver.archiveRootObject(coins, toFile: Unlockable.CoinURL.path!)
}
func saveStats(){
    NSKeyedArchiver.archiveRootObject(statistics, toFile: Unlockable.StatsURl.path!)
}
