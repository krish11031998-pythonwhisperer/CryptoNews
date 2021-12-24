//
//  ImageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/04/2021.
//

import SwiftUI
import UIKit
import SVGKit

struct StandardImage:ViewModifier{
    var size:CGSize
    var contentMode:ContentMode
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: self.contentMode)
            .frame(width: self.size.width,height: self.size.height)
            .imageSpring()
    }
}

extension Image{
    func standardImageView(size:CGSize,contentMode:ContentMode) -> some View{
        return self.resizable().modifier(StandardImage(size: size, contentMode: contentMode))
    }
}

struct ImageView:View{
    @State var image:UIImage?
    @StateObject var IMD:ImageDownloader = .init()
    var url:String?
    var width:CGFloat
    var height:CGFloat
    var contentMode:ContentMode
    var autoHeight:Bool = false
    var heading:String? = nil
    var alignment:Alignment
    var isPost:Bool
    var headingSize:CGFloat
    var isHidden:Bool
    let testMode:Bool = false
    let quality:JPEGQuality
    var clipping:Clipping
    
    init(img:UIImage? = nil,url:String? = nil,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,autoHeight:Bool = false,isPost:Bool = false,headingSize:CGFloat = 35,isHidden:Bool = false,quality:JPEGQuality = .low,isModel:Bool = false,clipping:Clipping = .clipped){
        self._image = .init(wrappedValue: img)
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.autoHeight = autoHeight
        self.heading = heading
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
        self.isHidden = isHidden
        self.quality = quality
        self.clipping = clipping
//        self._IMD = .init(wrappedValue: .init(url: url,quality: quality,isModelURL: isModel))
    }
            
    func img_h(img:UIImage? = nil) -> CGFloat{
        var h = self.height
        if self.autoHeight && img != nil{
            let ar = UIImage.aspectRatio(img: img)
            h = self.width/ar
            h = self.autoHeight && h < 250 ? h * 1.5  : h
        }
        return h
    }
    
    var mainImg:UIImage?{
        self.image ?? self.IMD.image
    }
    
    
    var imgSize:CGSize{
        guard let mainImg = mainImg else {return .zero}
        return .init(width: self.width, height: self.img_h(img: mainImg))
    }
    
    @ViewBuilder var imgUIImageView:some View{
        if let img = mainImg{
            Image(uiImage: img)
                .standardImageView(size: self.imgSize, contentMode: .fill)
        }else{
            Color.clear.frame(width: self.imgSize.width, height: self.imgSize.height, alignment: .center)
        }
    }
    
    @ViewBuilder var imgView:some View{
        if let urlStr = self.url,let url = URL(string: urlStr),urlStr.contains("svg") {
            SVGImage(url: url, size: self.imgSize)
                .frame(width: self.imgSize.width, height: self.imgSize.height, alignment: .center)
//                .clipContent(clipping: self.clipping)
        }else{
            self.imgUIImageView
        }
    }
    
    func imgView(w _w:CGFloat? = nil,h _h:CGFloat? = nil) -> some View{
        return ZStack(alignment: .center) {
            BlurView(style: .dark)
            self.imgView
            if self.heading != nil{
                lightbottomShadow.frame(width: self.width, height: self.imgSize.height, alignment: .center)
                self.overlayView(h: self.imgSize.height)
            }
            if self.isHidden && !self.IMD.loading{
                BlurView(style: .regular)
            }
        }.frame(width: self.imgSize.width,height: self.imgSize.height)
        .onAppear {
            if let url = self.url , !url.contains("svg") && self.IMD.image == nil{
                self.IMD.getImage(url: url)
            }
        }
    }
    
    func overlayView(h : CGFloat) -> some View{
        return
            GeometryReader{g in
                let w = g.frame(in: .local).width
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    MainText(content: self.heading!, fontSize: self.headingSize, color: .white, fontWeight: .regular)
                    RoundedRectangle(cornerRadius: 20).frame(width: w, height: 2, alignment: .center).foregroundColor(.white.opacity(0.35))
                    if self.isPost{
                        self.buttons(w: w, h: h)
                    }else{
                        Spacer().frame(height:25)
                    }
                }.padding()
                .frame(width: self.width, height: h, alignment: .center)
            }
    }
    
    
    func buttons(w:CGFloat,h:CGFloat) -> some View{
        let size:CGSize = .init(width: self.width > totalWidth * 0.5 ? 20 : 10, height: self.width > totalWidth * 0.5 ? 20 : 10)
        
        return HStack(alignment: .center, spacing: 25) {
            SystemButton(b_name: "hand.thumbsup", b_content: "\(10)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                print("pressed Like")
            }
            SystemButton(b_name: "bubble.left", b_content: "\(5)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                print("pressed Comment")
            }
            Spacer()
        }.padding(.leading,10)
    }
    
    var body: some View{
        self.imgView().clipContent(clipping: clipping)
    }
    
}


struct SVGImage:UIViewRepresentable{
    
    var url:URL
    var size:CGSize
    
    init(url:URL,size:CGSize){
        self.url  = url
        self.size = size
    }
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgView = SVGKImage(contentsOf:  self.url)
        return SVGKFastImageView(svgkImage: svgView ?? SVGKImage())
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
         uiView.contentMode = .scaleAspectFit
         uiView.image.size = size
     }
}
