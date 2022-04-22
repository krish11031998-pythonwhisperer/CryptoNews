//
//  SceneKitView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 06/03/2022.
//

import SwiftUI
import SceneKit

public struct SceneKitViewRepresentable:UIViewRepresentable{
    var size:CGSize
    var view:SCNView
    @Binding var allowCameraControl:Bool
    var scene:SCNScene? = nil
    @Binding var url:URL?
    
    
    public init(scene:SCNScene? = nil,url:Binding<URL?> = .constant(nil),size:CGSize,allowCameraControl:Binding<Bool>){
        self.scene = scene
        self._url = url
        self.view = SCNView(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        self.view.backgroundColor = .clear
        self.size = size
        self._allowCameraControl = allowCameraControl
    }
    
    public func makeUIView(context: Context) -> SCNView {
        self.view.autoenablesDefaultLighting = true
        self.view.allowsCameraControl = self.allowCameraControl
        if let scene = scene {
            self.view.scene = scene
        }
        return view
    }

    
    public func updateUIView(_ uiView: SCNView, context: Context) {
        if uiView.scene == nil{
            if let url = self.url {
                do {
                    uiView.scene = try SCNScene(url: url)
                }catch{
                    print("Error while loading the scene !",error.localizedDescription)
                }
            }
        }
        
        if self.allowCameraControl != uiView.allowsCameraControl{
            uiView.allowsCameraControl = self.allowCameraControl
        }
    }
    
}
