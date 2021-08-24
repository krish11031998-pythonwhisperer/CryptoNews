//
//  RedditCardView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/08/2021.
//

import SwiftUI

struct ImageCardView: View {
    var data:AssetNewsData
    var size:CGSize
    
    init(data:AssetNewsData,size:CGSize){
        self.data = data
        self.size = size
    }
    
    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            ZStack(alignment: .center) {
                BlurView(style: .dark)
                ImageView(url: self.data.image, heading: self.data.title, width: w - 5, height: h - 5, contentMode: .fill, alignment: .center, isPost: false, headingSize: 13)
            }
            
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

//struct RedditCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        RedditCardView()
//    }
//}
