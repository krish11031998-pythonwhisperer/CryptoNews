//
//  RecentNewsCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNewsCard: View {
    var data:CrybseNews
    var cardSize:CGSize
    @Namespace var animation
    var isSelected:Bool
    let font_color:Color = .white
    init(data:CrybseNews,size:CGSize,selected:Bool){
        self.data = data
        self.cardSize = size
        self.isSelected = selected
    }
    
    func newsDetails(size:CGSize) -> some View{
        VStack(alignment: .leading, spacing: 5){
            MainText(content: self.data.source_name ?? "Title", fontSize: isSelected ? 13 : 9, color: .gray, fontWeight: .bold)
            MainText(content: self.data.title ?? "Title", fontSize: isSelected ? 20 : 13, color: font_color, fontWeight: .semibold)
            
            if let sentiment = data.sentiment{
                let color = sentiment.lowercased() == "positive" ? Color.green : sentiment.lowercased() == "negative" ? Color.red : Color.gray
                let emoji = sentiment.lowercased() == "postive" ? "😁" : sentiment.lowercased() == "negative" ? "😓" : "😐"
                HStack(alignment: .center, spacing: 2.5) {
                    MainText(content: "\(emoji) ", fontSize: 12,color: .white)
                    MainText(content: String(format: "%.1f", sentiment), fontSize: 12, color: .white)
                }.padding(7.5)
                .padding(.horizontal,2.5)
                .background(color.overlay(BlurView(style: .systemThinMaterial)))
                .clipShape(Capsule())
                
            }
        }.frame(width: size.width, height: size.height, alignment: .topLeading)
        .fixedSize()
    }
    
    var body:some View{
            let w = cardSize.width
            let h = cardSize.height
            let details_h = h * (isSelected ? 0.375 : 1)
            
            VStack(alignment: .leading, spacing: 10) {
                if isSelected{
                    ImageView(url: self.data.image_url, width: w, height: h * 0.625 - 10, contentMode: .fill, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .matchedGeometryEffect(id: "image", in: self.animation)
                }
                HStack(alignment: .top, spacing: 10) {
                    self.newsDetails(size: .init(width: w * (isSelected ? 1 : 0.7), height: h * (isSelected ? 0.375 : 1) - (isSelected ? 10 : 0)))
                    if !isSelected{
                        ImageView(url: self.data.image_url, width: w * 0.3 - 10, height: h * 0.9, contentMode: .fill, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .matchedGeometryEffect(id: "image", in: self.animation)
                    }
                }.frame(width: w, height: details_h, alignment: .center)
            }.frame(width: w, height: h, alignment: .leading)
    }
    
}

//struct RecentNewsCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentNewsCard()
//    }
//}
