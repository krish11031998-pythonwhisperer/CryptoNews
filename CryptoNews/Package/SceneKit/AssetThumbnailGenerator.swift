//
//  AssetThumbnailGenerator.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 06/03/2022.
//

import Foundation
import SceneKit
import QuickLookThumbnailing

class AssetThumbnailGenerator:ObservableObject{
    @Published var image:UIImage? = nil
    @Published var loading:Bool = false
    var resourceName:String
    var withExtension:String
    var size:CGSize
    
    init(resourceName:String,withExtension:String = "usdz",size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.35)){
        self.resourceName = resourceName
        self.withExtension = withExtension
        self.size = size
    }
    
    func generateThumbnail(){
        guard let url = Bundle.main.url(forResource: self.resourceName, withExtension: self.withExtension) else {print("Can't find the resource");return}
        let scale = UIScreen.main.scale
        
        let reqeust = QLThumbnailGenerator.Request(fileAt: url, size: self.size, scale: scale, representationTypes: .thumbnail)
        
        let generator = QLThumbnailGenerator.shared
        
        DispatchQueue.main.async {
            if !self.loading{
                self.loading.toggle()
            }
        }
        
        generator.generateRepresentations(for: reqeust) { (thumbnail, type, err) in
            if err != nil{
                print("Error while fetching the thumbnail for the asset : ",err?.localizedDescription ?? "No Error")
            }
            
            DispatchQueue.main.async {
                if let thumbnailImage = thumbnail?.uiImage{
                    self.image = thumbnailImage
                }
                
                if self.loading{
                    self.loading.toggle()
                }
            }
        }
    }
}
