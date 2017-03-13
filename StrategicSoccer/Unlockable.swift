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
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let FlagURL = DocumentsDirectory.appendingPathComponent("flags")
    static let CoinURL = DocumentsDirectory.appendingPathComponent("coins")
    static let StatsURl = DocumentsDirectory.appendingPathComponent("statistics")
    var unlockedFlags: [String] = ["UNITED STATES", "FRANCE", "CHINA", "JAPAN","CANADA","GERMANY", "MEXICO", "AUSTRALIA","SPAIN","ITALY"]
    var numberCoins = 50
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.decodeObject(forKey: PropertyKey.flagKey) == nil{
            aDecoder.encode(unlockedFlags, forKey: PropertyKey.flagKey)
        }else{
            unlockedFlags = aDecoder.decodeObject(forKey: PropertyKey.flagKey) as! [String]
        }
        if aDecoder.decodeObject(forKey: PropertyKey.coinKey) == nil{
            aDecoder.encode(numberCoins, forKey: PropertyKey.coinKey)
        }else{
            numberCoins = aDecoder.decodeObject(forKey: PropertyKey.coinKey) as! Int
        }
        if aDecoder.decodeObject(forKey: PropertyKey.statsKey) == nil{
            aDecoder.encode(statistics, forKey: PropertyKey.statsKey)
        }else{
            statistics = aDecoder.decodeObject(forKey: PropertyKey.statsKey) as! [String:Int]
        }
    }
    func encode(with aCoder: NSCoder){
        aCoder.encode(unlockedFlags, forKey: PropertyKey.flagKey)
        aCoder.encode(numberCoins, forKey: PropertyKey.coinKey)
        aCoder.encode(statistics, forKey: PropertyKey.statsKey)
    }
}
func saveCoins(){
    NSKeyedArchiver.archiveRootObject(coins, toFile: Unlockable.CoinURL.path)
}
func saveStats(){
    NSKeyedArchiver.archiveRootObject(statistics, toFile: Unlockable.StatsURl.path)
}
