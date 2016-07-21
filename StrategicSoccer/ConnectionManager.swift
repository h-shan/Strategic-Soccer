//
//  ConnectionManager.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import MultipeerConnectivity
import MultipeerConnectivity
protocol ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String])
    func receiveMove(manager : ConnectionManager, move: [String])
    func receivePositions(manager : ConnectionManager, positions: [String])
    func receiveScreenSize(manager : ConnectionManager, size: [String])
}
class ConnectionManager : NSObject{
    private let serviceBrowser : MCNearbyServiceBrowser
    private let SoccerServiceType = "Strat-Soccer"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    var delegate:ConnectionManagerDelegate?
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: SoccerServiceType)
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: SoccerServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    deinit{
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    func getServiceAdvertiser() -> MCNearbyServiceAdvertiser{
        return serviceAdvertiser
    }
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    func sendScreenSize(screenSize: CGRect){
        let sendString = String(format: "%f %f", screenSize.width, screenSize.height)
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(sendString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch{
                NSLog("%@","\(error)")
            }
        }
        
    }
    func sendMove(player:Player, velocity: CGVector) {
        NSLog("%@", "player: \(player.name), x:\(velocity.dx), y:\(velocity.dy)")
        let sendString = String(format:"%@ %f %f", player.name!, velocity.dx, velocity.dy)
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(sendString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch{
                NSLog("%@","\(error)")
            }
        }
    }
    func sendPosition(scene: GameScene){
        NSLog("sendPosition")
        var sendString = String(format:"%f %f ",scene.ball.position.x, scene.ball.position.y)
        for player in scene.players{
            sendString += String(format: "%f %f ",player.position.x, player.position.y)
        }
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(sendString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch{
                NSLog("%@","\(error)")
            }
        }
    }
}



extension ConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError){
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void){
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}
extension ConnectionManager : MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
    }
    
    
}
extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ConnectionManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let strArr = str.characters.split{$0 == " "}.map(String.init)
        if strArr.count == 3{
            self.delegate?.receiveMove(self, move: strArr)
        }else if strArr.count == 2{
            self.delegate?.receiveScreenSize(self, size: strArr)
        }else{
            self.delegate?.receivePositions(self, positions: strArr)
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    
}