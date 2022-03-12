//
//  SceneView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 06/03/2022.
//

import SwiftUI
import SceneKit

struct SceneKitView: View {
    
    var model_url:URL?
    var model_name:String?
    var size:CGSize
    @Binding var allowControl:Bool
    init(model_name:String? = nil, model_url:URL? = nil,size:CGSize = .init(width: totalWidth * 1, height: totalHeight * 0.5),allowControlState:Binding<Bool>? = nil,allowControl:Bool = false){
        self.model_name = model_name
        self.model_url = model_url
        self.size = size
        self._allowControl = allowControlState ?? .constant(allowControl)
    }
    
    var scene:SCNScene?{
        guard let url = self.sceneURL else{return nil}
        var scene:SCNScene? = nil
        do{
            scene = try SCNScene(url: url)
        }catch{
            print("(Error) Can't load the SCNScene! : ",error.localizedDescription)
        }
        return scene
    }
    
    var sceneURL:URL?{
        if let model_url = self.model_url{
            return model_url
        }
        guard let url = Bundle.main.url(forResource: self.model_name, withExtension: "usdz") else {return nil}
        return url
    }
    
    @ViewBuilder var sceneView:some View{
        if let scene = self.scene {
            SceneKitViewRepresentable(scene: scene,size: self.size, allowCameraControl: self.$allowControl)
        }else{
            ProgressView()
        }
        
    }
    
    var body: some View {
        self.sceneView
            .frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView(model_name: "Range_Rover_Evoque",allowControl: true)
            .basicCard()
    }
}
