//
//  BackgroundImageShadowView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 09/03/2022.
//

import SwiftUI

struct BackgroundImageShadowView: ViewModifier {
    var img_name:String
    var bg:AnyView
    var size:CGSize
    
    init(img_name:String,bg:AnyView = Color.AppBGColor.anyViewWrapper(),size:CGSize = .zero){
        self.img_name =  img_name
        self.bg = bg
        self.size = size
    }
    
    func body(content:Content) -> some View {
        ZStack(alignment: .topTrailing) {
            SystemButton(b_name: self.img_name, color: .white, haveBG: true,size: .init(width: self.size.width * 0.15, height: self.size.width * 0.15), clipping: .circleClipping) {}
            .offset(x: 2.5, y: -2.5)
            content
        }
        .basicCard(size:self.size,background: self.bg)
        .borderCard(color: .white, clipping: .roundClipping)
    }
}



struct BackgroundImageShadowView_Previews: PreviewProvider {


    static var previews: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            MainSubHeading(heading: "Title", subHeading: "SubTitle", headingSize: 17.5, subHeadingSize: 13.5,headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium, spacing: 1, alignment: .topLeading)
                .padding()
        }
        .frame(width: 250, height: 350, alignment: .leading)
//        .modifier(BackgroundImageShadowView(img_name: "home", size: .init(width: 350, height: 350)))
        .modifier(BackgroundImageShadowView(img_name: "house",size: .init(width: 250, height: 350)))
    }
}
