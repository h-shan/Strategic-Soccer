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
    // uncomment below to obtain all flags!
    //var unlockedFlags: [String] = ["AFGHANISTAN","ALBANIA","ALGERIA","AMERICAN SAMOA","ANDORRA","ANGOLA","ANGUILLA","ANTIGUA AND BARBUDA","ARGENTINA","ARMENIA","ARUBA","AUSTRALIA","AUSTRIA" ,"AZERBAIJAN","BAHAMAS","BAHRAIN","BANGLADESH","BARBADOS","BELARUS","BELGIUM","BELIZE","BENIN","BHUTAN","BOLIVIA","BOSNIA AND HERZEGOVINA","BOTSWANA","BRAZIL","BRITISH VIRGIN ISLANDS","BRUNEI","BULGARIA","BURKINA FASO","BURUNDI","CABO VERDE","CAMBODIA","CAMEROON","CANADA","CAYMAN ISLANDS","CENTRAL AFRICAN REPUBLIC","CHAD","CHILE","CHINA","COLOMBIA","COMOROS","CONGO, DEM. REP. OF THE","CONGO, REP. OF THE","COOK ISLANDS","COSTA RICA","COTE D'IVOIRE","CROATIA","CUBA","CURACAO","CYPRUS","CZECH REPUBLIC","DENMARK","DJIBOUTI","DOMINICA","DOMINICAN REPUBLIC","ECUADOR","EGYPT","EL SALVADOR","ENGLAND","EQUATORIAL GUINEA","ERITREA","ESTONIA","ETHIOPIA","FAROE ISLANDS","FIJI","FINLAND","FRANCE","GABON","GAMBIA","GEORGIA","GERMANY","GHANA","GIBRALTAR","GREECE","GRENADA","GUAM","GUATEMALA","GUINEA","GUINEA-BISSAU","GUYANA","HAITI","HONDURAS","HONG KONG","HUNGARY","ICELAND","INDIA","INDONESIA","IRAN","IRAQ","IRELAND","ISRAEL","ITALY","JAMAICA","JAPAN","JORDAN","KAZAKHSTAN","KENYA","KIRIBATI","KOSOVO","KUWAIT","KYRGYZSTAN","LAOS","LATVIA","LEBANON","LESOTHO","LIBERIA","LIBYA","LIECHTENSTEIN","LITHUANIA","LUXEMBOURG","MACAU","MACEDONIA","MADAGASCAR","MALAWI","MALAYSIA","MALDIVES","MALI","MALTA","MAURITANIA","MAURITIUS","MEXICO","MOLDOVA","MONACO","MONGOLIA","MONTENEGRO","MONTSERRAT","MOROCCO","MOZAMBIQUE","MYANMAR","NAMIBIA","NAURU","NEPAL","NETHERLANDS","NEW CALEDONIA","NEW ZEALAND","NICARAGUA","NIGER","NIGERIA","NORTH KOREA","NORTHERN IRELAND","NORWAY","OMAN","PAKISTAN","PALESTINE","PANAMA","PAPUA NEW GUINEA","PARAGUAY","PERU","PHILIPPINES","POLAND","PORTUGAL","PUERTO RICO","QATAR","ROMANIA","RUSSIA","RWANDA","ST KITTS AND NEVIS","ST LUCIA","ST VINCENT AND THE GRENADINES","SAMOA","SAN MARINO","SAO TOME AND PRINCIPE","SAUDI ARABIA","SCOTLAND","SENEGAL","SERBIA","SEYCHELLES","SIERRA LEONE","SINGAPORE","SLOVAKIA","SLOVENIA","SOLOMON ISLANDS","SOMALIA","SOUTH AFRICA","SOUTH KOREA","SOUTH SUDAN","SPAIN","SRI LANKA","SUDAN","SURINAME","SWAZILAND","SWEDEN","SWITZERLAND","SYRIA","TAIWAN","TAJIKISTAN","TANZANIA","THAILAND","TIMOR-LESTE","TOGO","TONGA","TRUNIDAD AND TOBAGO","TUNISIA","TURKEY","TURKMENISTAN","TURKS AND CAICOS ISLANDS","U.S. VIRGIN ISLANDS","UGANDA","UKRAINE","UNITED ARAB EMIRATES","UNITED STATES","URUGUAY","UZBEKISTAN","VANUATU","VENEZUELA","VIETNAM","WALES","YEMEN","ZAMBIA","ZIMBABWE"]

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
