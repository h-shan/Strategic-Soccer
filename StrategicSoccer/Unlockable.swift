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
}
class Unlockable: NSObject, NSCoding{
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("flags")
    var unlockedFlags: [String] = ["UNITED STATES", "FRANCE", "CHINA", "JAPAN","CANADA","GERMANY", "MEXICO", "AUSTRALIA","SPAIN","ITALY"]
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.decodeObjectForKey(PropertyKey.flagKey) == nil{
            aDecoder.encodeObject(unlockedFlags, forKey: PropertyKey.flagKey)
        }else{
            unlockedFlags = aDecoder.decodeObjectForKey(PropertyKey.flagKey) as! [String]
        }
    }
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(unlockedFlags, forKey: PropertyKey.flagKey)
    }
}
