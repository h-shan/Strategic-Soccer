//
//  SocketIOManager.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 4/2/17.
//  Copyright © 2017 HS. All rights reserved.
//

import SocketIO
import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.167:3000")! as URL)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServerWithUsername(_ username: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", username)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
    }
    
    func exitChatWithUsername(_ username: String, completionHandler: () -> Void) {
        socket.emit("exitUser", username)
        completionHandler()
    }
    
    func connectGame(_ username: String, otherUsername: String) {
        socket.emit("connectGame", username, otherUsername)
    }
    
    func sendGameInfo(_ opponentName: String, mode: String, flag: String, screenWidth: CGFloat, screenHeight: CGFloat, friction: Float) {
        socket.emit("gameInfo", opponentName, mode, flag, screenWidth, screenHeight, friction)
    }
    
    func sendPause(_ opponentName: String, pauseOption: String) {
        socket.emit("pause", opponentName, pauseOption)
    }
}

extension CGFloat: SocketData {}
extension Float: SocketData {}

