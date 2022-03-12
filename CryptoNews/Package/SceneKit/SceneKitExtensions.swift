//
//  SceneKitExtensions.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 06/03/2022.
//

import Foundation
import UIKit
import SceneKit
import AVKit

extension SCNView{
        
    func enableTapRecognizer(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let tapRecoginizer = UITapGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(tapRecoginizer)
    }
    
    func enableLongPressRecognizer(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let longTapRecoginizer = UILongPressGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(longTapRecoginizer)
    }
    
    func enablePanGesture(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let panRecoginizer = UIPanGestureRecognizer(target: target, action: selector)
        panRecoginizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panRecoginizer)
    }
    
    func enableTwoFingerPanGesture(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let panRecognizer = UIPanGestureRecognizer(target: target, action: selector)
        panRecognizer.minimumNumberOfTouches = 2
        self.addGestureRecognizer(panRecognizer)
    }
    
    func enablePinchGesture(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let pinchRecoginizer = UIPinchGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(pinchRecoginizer)
    }
    
    func getClosestNode(location:CGPoint) -> SCNHitTestResult?{
        return self.hitTest(location).first
    }
    
    func getAllNodes(location:CGPoint) -> [SCNHitTestResult]{
        let res = self.hitTest(location)
        return res
    }
    
        
    func getNodeName(location:CGPoint) -> String?{
        guard let res = self.getClosestNode(location: location)?.node.name else {return nil}
        return  res
    }
    
    
    func deleteNode(name:String){
        let node = self.scene?.rootNode.childNode(withName: name, recursively: true)
        if let node = node{
            node.removeFromParentNode()
        }
    }
    
    func createPlaneNode(location: SCNVector3,name _name:String?=nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil) -> SCNNode{
        let text = SCNText(string: "\(idx)", extrusionDepth: 4)
        text.font = .init(descriptor: .init(name: "Avenir", size: 5), size: 5)
        text.firstMaterial?.diffuse.contents = UIColor.init(.white)
        text.firstMaterial?.specular.contents = UIColor.init(.blue)
        //SCNTextNode
        let textnode = SCNNode(geometry: text)
        let name = _name ?? "annotation-\(idx)"
//        textnode.name = name

        let (min, max) = (text.boundingBox.min, text.boundingBox.max)
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        textnode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
        
//        self.deleteNode(name: name)
        
        let plane = SCNPlane(width: CGFloat(10), height: CGFloat(10))
        plane.cornerRadius = 5
        let planeNode = SCNNode(geometry: plane)
//        planeNode.name = "plane-\(name)"
        planeNode.name = name
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        planeNode.position = location
        planeNode.position.z = 1
//        textnode.eulerAngles = planeNode.eulerAngles
        planeNode.addChildNode(textnode)
        
        
        if let handler = handler{
            handler(location,name)
        }
        return planeNode
    }

    func addVideoScreen(screenLocation:SCNVector3,url:URL? = nil,card:CGSize,avplayer:AVPlayer? = nil){
        var _player:AVPlayer? = nil
        if let avp = avplayer{
            _player = avp
        }else if let url = url{
            _player = .init(url: url)
        }
        
        guard let player = _player else {return}
        
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        
        plane.firstMaterial?.diffuse.contents = player
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
        self.play(nil)
//        player.play()

        self.scene?.rootNode.addChildNode(planeNode)
    }
//
    func addVideoScreenFrame(screenLocation:SCNVector3,card:CGSize) -> SCNNode{
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
        self.play(nil)
        self.scene?.rootNode.addChildNode(planeNode)
        return planeNode
    }
    
    
    func createTVScreen(location:SCNVector3,local_id:String = "sample",cardSize:CGSize = .init(width: 75, height: 50),handler: ((URL) -> Void)? = nil){
        self.deleteNode(name: "playerNode")
        guard let url = Bundle.main.url(forResource: local_id, withExtension: "mp4") else {return}
        if let handler = handler{
            handler(url)
        }else{
            self.addVideoScreen(screenLocation: location, url: url, card: cardSize)
        }
    }
    
    func addNodeToRootNode(node:SCNNode){
        self.scene?.rootNode.addChildNode(node)
    }
    
    func createAnnotation(location: SCNVector3,name:String? = nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil){
        let planeNode = self.createPlaneNode(location: location, name:name,idx: idx, handler: handler)
        self.scene?.rootNode.addChildNode(planeNode)
        

    }
    func createAnnotation(node:SCNNode? = nil){
        if let node = node{
            self.scene?.rootNode.addChildNode(node)
        }
    }
    
}
