//
//  Timer.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/17/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation
class Timer {
    var startTime: NSDate?
    var endTime: NSDate?
    init(){
        
    }
    func start(){
        startTime = NSDate()
    }
    func stop()->NSTimeInterval{
        endTime = NSDate()
        return endTime!.timeIntervalSinceDate(startTime!)
    }
    func secondsToString (seconds : NSTimeInterval) -> (String) {
        let minutes = Int(seconds/60)
        let seconds = Int(seconds%60)
       
        return String.localizedStringWithFormat("%d:%d",minutes,seconds)
    }
}
