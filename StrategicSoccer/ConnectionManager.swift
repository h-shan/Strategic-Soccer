//
//  ConnectionManager.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import MultipeerConnectivity
import SpriteKit
protocol ConnectionManagerDelegate {
    func connectedDevicesChanged(_ manager : ConnectionManager, connectedDevices: [String])
    func receiveMove(_ manager : ConnectionManager, move: [String])
    func receivePositions(_ manager : ConnectionManager, positions: [String])
    func receiveStart(_ manager: ConnectionManager, settings: [String])
    func receivePause(_ manager: ConnectionManager, pauseType: String)
    func receivePositionMove(_ manager: ConnectionManager, positionMove:[String])
    func receiveVelocities(_ manager: ConnectionManager, velocities:[String])
    func receiveSync(_ manager: ConnectionManager, turn: String)
    func receiveMisc(_ manager: ConnectionManager, message: [String])
    func receivePositionVelocity(_ manager: ConnectionManager, positionVelocity: [String])
    func receiveHighlight(_ manager: ConnectionManager, playerName: String)
}
class ConnectionManager : NSObject{
    fileprivate let serviceBrowser : MCNearbyServiceBrowser
    fileprivate let SoccerServiceType = "Strat-Soccer"
    fileprivate let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    fileprivate let serviceAdvertiser : MCNearbyServiceAdvertiser
    var connectedDevice:[MCPeerID]?
    var delegate:ConnectionManagerDelegate?
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: SoccerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: SoccerServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    deinit{
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    func getServiceAdvertiser() -> MCNearbyServiceAdvertiser{
        return serviceAdvertiser
    }
    func getServiceBrowser() -> MCNearbyServiceBrowser{
        return serviceBrowser
    }
    func connectToDevice(_ deviceName: String){
        for peer in session.connectedPeers{
            if peer.displayName == deviceName{
                connectedDevice = [peer]
            }
        }
    }
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func sendMove(_ player:Player, velocity: CGVector, position: CGPoint) {
        NSLog("%@", "player: \(player.name), x:\(velocity.dx), y:\(velocity.dy)")
        let sendString = String(format:"%@ %@ %f %f %f %f %f", "move",player.name!,velocity.dx, velocity.dy, position.x, position.y, Date.timeIntervalSinceReferenceDate)
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    func sendPause(_ pauseType: String){
        if connectedDevice != nil{
            stringSend("pause " + pauseType)
        }
    }
    func sendVelocities(_ scene: GameScene){
        var sendString = String(format:"%@ %f %f ","velocities",scene.ball.physicsBody!.velocity.dx, scene.ball.physicsBody!.velocity.dy)
        for player in scene.players{
            sendString += String(format: "%f %f ",player.physicsBody!.velocity.dx, player.physicsBody!.velocity.dy)
        }
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    func sendPosition(_ scene: GameScene){
        var sendString = String(format:"%@ %f %f ","position",scene.ball.position.x, scene.ball.position.y)
        for player in scene.players{
            sendString += String(format: "%f %f ",player.position.x, player.position.y)
        }
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    func sendPositionVelocity(_ scene: GameScene, reset: Bool) {
        var sendString = String(format:"%@ %f %f ", "positionVelocity", scene.ball.position.x, scene.ball.position.y)

        for player in scene.players{
            sendString += String(format: "%f %f ",player.position.x, player.position.y)
        }
        sendString += String(format:"%f %f ", scene.ball.physicsBody!.velocity.dx, scene.ball.physicsBody!.velocity.dy)
        for player in scene.players{
            sendString += String(format: "%f %f ",player.physicsBody!.velocity.dx, player.physicsBody!.velocity.dy)
        }
        sendString += String(format:"%f", Date.timeIntervalSinceReferenceDate)
        if reset {
            sendString += " reset"
        }
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    func sendStart(_ scene: GameScene){
        let flag = scene.countryA!
        print("sendStart")
        
        var stringToSend = "start "
        if scene.isHost {
            stringToSend += modeString[scene.mode]! + " "
        } else {
            stringToSend += "joined "
        }
        stringToSend += String(format: "%@ %f %f %f", flag, screenWidth, screenHeight, defaultFriction)
        if connectedDevice != nil{
            stringSend(stringToSend)
        }
    }
    func sendPositionMove(_ nodeA: String, positionA: CGPoint, velocityA: CGVector, nodeB: String, positionB: CGPoint, velocityB: CGVector){
        let sendString = String(format: "%@ %@ %f %f %f %f %@ %f %f %f %f", "positionMove", nodeA, positionA.x, positionA.y, velocityA.dx, velocityA.dy, nodeB, positionB.x, positionB.y, velocityB.dx, velocityB.dy)
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    func sendSync(_ turnA: Bool){
        let appendBool = turnA.toString()
        let sendString = String(format:"%@ %@", "sendSync", appendBool)
        if connectedDevice != nil{
            stringSend(sendString)
        }
    }
    
    func sendHighlight(_ playerName: String) {
        stringSend("highlight " + playerName)
    }
    
    func stringSend(_ message: String){
        DispatchQueue.main.async(execute: {
            do {
                try self.session.send(message.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: self.connectedDevice!, with: MCSessionSendDataMode.reliable)
            }
            catch{
                NSLog("%@","\(error)")
            }
        })
    }
    
}



extension ConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error){
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void){
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}
extension ConnectionManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
    }
}
extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

extension ConnectionManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async(execute: {
            NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
            self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: {
            let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            var strArr = str.characters.split{$0 == " "}.map(String.init)
            let tag = strArr.removeFirst()
            switch(tag) {
            case "start":
                self.connectedDevice = [peerID]
                self.delegate?.receiveStart(self, settings: strArr);
                break
            case "move":self.delegate?.receiveMove(self, move: strArr); break
            case "position":self.delegate?.receivePositions(self, positions: strArr); break
            case "pause":self.delegate?.receivePause(self, pauseType:strArr[0]); break
            case "positionMove": self.delegate?.receivePositionMove(self, positionMove: strArr); break
            case "velocities": self.delegate?.receiveVelocities(self, velocities: strArr); break
            case "sendSync": self.delegate?.receiveSync(self, turn: strArr[0]); break
            case "positionVelocity": self.delegate?.receivePositionVelocity(self, positionVelocity: strArr); break
            case "highlight": self.delegate?.receiveHighlight(self, playerName: strArr[0]); break
            default: self.delegate?.receiveMisc(self, message: strArr); break
            }
        })
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    
}
