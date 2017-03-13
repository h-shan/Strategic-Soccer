//
//  Timer.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/17/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation

class Timer{
    
    var startTime:Date?
    var elapsedTime:Double
    var started:Bool
    
    init(){
        started = false
        elapsedTime = 0
    }
    
    
    //Calling start() will cause the timer to begin counting or resume after a pause.
    func start(){
        guard !started else{
            return
        }
        startTime = Date()
        started = true
    }
    
    //pause() allows the timer to be momentarily stopped without the total time being affected.
    
    func pause(){
        elapsedTime = getElapsedTime()
        started = false
    }
    
    //reset() restores and stops the timer so it begins from zero seconds again.
    
    func reset(){
        elapsedTime = 0
        started = false
    }
    
    //getElapsedTime() returns the number of seconds that the timer has been running since the start time. Calling this function does not stop the timer.
    
    func getElapsedTime() -> Double{
        return started ? Date().timeIntervalSince(startTime!) + elapsedTime : elapsedTime
    }
    
    //restart() calls starts a clean timer running.
    
    func restart(){
        self.reset()
        self.start()
    }
    
    func secondsToString (_ seconds : TimeInterval) -> (String) {
        let minutes = Int(seconds/60)
        let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        if seconds < 10 {
            return String.localizedStringWithFormat("%d:0%d", minutes,seconds)
        }
        
        return String.localizedStringWithFormat("%d:%d",minutes,seconds)
    }
    
}
