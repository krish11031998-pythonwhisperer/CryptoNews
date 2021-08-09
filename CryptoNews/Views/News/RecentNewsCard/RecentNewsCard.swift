//
//  RecentNewsCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNewsCard: View {
    var data:AssetNewsData
    var cardSize:CGSize
    @Namespace var animation
    var isSelected:Bool
    
    init(data:AssetNewsData,size:CGSize,selected:Bool){
        self.data = data
        self.cardSize = size
        self.isSelected = selected
    }
    
    func newsDetails(size:CGSize) -> some View{
        VStack(alignment: .leading, spacing: 2.5){
            MainText(content: self.data.title ?? "Title", fontSize: isSelected ? 20 : 13, color: .white, fontWeight: .semibold)
            MainText(content: self.data.publisher ?? "Title", fontSize: isSelected ? 15 : 11, color: .white, fontWeight: .bold)
        }.frame(width: size.width, height: size.height, alignment: .leading)
        .fixedSize()
    }
    
    var body:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let details_h = h * (isSelected ? 0.375 : 1)
            VStack(alignment: .leading, spacing: 10) {
                if isSelected{
                    ImageView(url: self.data.image, width: w, height: h * 0.625 - 10, contentMode: .fill, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .matchedGeometryEffect(id: "image", in: self.animation)
                        
                }
                HStack(alignment: .top, spacing: 10) {
                    self.newsDetails(size: .init(width: w * (isSelected ? 1 : 0.7), height: h * (isSelected ? 0.375 : 1) - (isSelected ? 10 : 0)))
                    if !isSelected{
                        ImageView(url: self.data.image, width: w * 0.3 - 10, height: h, contentMode: .fill, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .matchedGeometryEffect(id: "image", in: self.animation)
                    }
                }.frame(width: w, height: details_h, alignment: .center)
            }.frame(width: w, height: h, alignment: .leading)
            
            
        }.frame(width: cardSize.width, height: cardSize.height, alignment: .leading)
    }
    
}

//struct RecentNewsCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentNewsCard()
//    }
//}
