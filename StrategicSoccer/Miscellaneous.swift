//
//  Miscellaneous.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 4/4/17.
//  Copyright © 2017 HS. All rights reserved.
//

import Foundation

struct Pause {
    static let pause = "pause"
    static let resume = "resume"
    static let restart = "restart"
    static let quit = "quit"
}

let player3Dict: [String: String] = [
    "playerA1" : "playerB2",
    "playerA2" : "playerB1",
    "playerA3" : "playerB3",
    "playerB1" : "playerA2",
    "playerB2" : "playerA1",
    "playerB3" : "playerA3"
]

let player4Dict: [String: String] = [
    "playerA1" : "playerB2",
    "playerA2" : "playerB1",
    "playerA3" : "playerB4",
    "playerA4" : "playerB3",
    "playerB1" : "playerA2",
    "playerB2" : "playerA1",
    "playerB3" : "playerA4",
    "playerB4" : "playerA3"
]

let intToPOption: [Int: PlayerOption] = [
    3: PlayerOption.three,
    4: PlayerOption.four
]
