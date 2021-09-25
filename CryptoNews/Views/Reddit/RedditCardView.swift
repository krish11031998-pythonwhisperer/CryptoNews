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
            let w = size.width
            let h = size.height
            ZStack(alignment: .bottom) {
                BlurView(style: .dark).frame(width: w, height: h, alignment: .center)
                ImageView(url: self.data.link, heading: self.data.title, width: w, height: h, contentMode: .fill, alignment: .center, isPost: false, headingSize: 13)
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
