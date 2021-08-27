//
//  PostCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/08/2021.
//

import SwiftUI

enum PostCardType{
    case Tweet
    case Reddit
}

struct PostCard: View {
    var cardType:PostCardType
    var data:AssetNewsData
    var size:CGSize
    var font_color:Color
    var const_size:Bool
    
    init(cardType:PostCardType,data:AssetNewsData,size:CGSize,font_color:Color = .white,const_size:Bool = false){
        self.cardType = cardType
        self.data = data
        self.size = size
        self.font_color = font_color
        self.const_size = const_size
    }
    
    var card:some View{
        let w = size.width - 20
        let h = size.height - 20
        
        let view =
            ZStack(alignment: .bottom) {
                Color.mainBGColor.frame(width: size.width, height: size.height * 0.15, alignment: .center)
                BlurView(style: .dark)
                VStack(alignment: .leading, spacing: 15) {
                    self.Header(data: data, size: .init(width: w, height: h * 0.1))
                    if let body = self.data.body{
                        MainText(content: body, fontSize: 14, color: font_color, fontWeight: .regular)
                            .fixedSize(horizontal: false, vertical: true)
                    }else if let title = self.data.title{
                        MainText(content: title, fontSize: 14, color: font_color, fontWeight: .regular)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if self.data.link?.isImgURLStr() ?? false{
                        ImageView(url: self.data.link, width: w, height: h * 0.45, contentMode: .fill, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    Spacer(minLength: 0)
                    Divider().frame(width: w, alignment: .center)
                    self.Footer(data: data, size: .init(width: w, height: h * 0.1))
                }.padding()
            }
            .frame(width: size.width, alignment: .center)
            .aspectRatio(contentMode: .fill)
            .frame(minHeight: self.const_size ? size.height : 0,maxHeight: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        
        return view
        
    }
    
    var body: some View {
        
//        if self.data.link?.isImgURLStr() ?? false{
//            ImageCardView(data: self.data, size: self.size)
//        }else{
            self.card
//        }
    }
}

extension PostCard{
    func Header(data:AssetNewsData,size:CGSize) -> AnyView{
        let w = size.width
        let h = size.height
        return AnyView(
            HStack(alignment: .center, spacing: 15) {
                ImageView(url: data.profile_image, width: h, height: h, contentMode: .fill, alignment: .center)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    MainText(content: self.cardType == .Reddit ?  "/\(data.subreddit ?? "Subreddit")" : "@\(data.twitter_screen_name ?? "Tweet")", fontSize: 15,color: font_color,fontWeight: .semibold)
                    MainText(content: "\(Date(timeIntervalSince1970: .init(data.time ?? 0)).stringDate())", fontSize: 10, color: .gray, fontWeight: .regular)
                }.frame(height: h, alignment: .leading)
                
                Spacer()
                if let currency = data.symbol{
                    MainText(content: currency, fontSize: 12,color: .white)
                        .padding(7.5)
                        .padding(.horizontal,2.5)
                        .frame(alignment:.leading)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Capsule())
                    
                }
            }.frame(width: w, height: h,alignment:.center)
        )
    }
    
    
    func Footer(data:AssetNewsData,size:CGSize) -> AnyView{
        let w = size.width
        let h = size.height
        
        return AnyView(
            HStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "suit.heart", b_content: "\(data.likes ?? 0)", color: font_color, haveBG:false,bgcolor: font_color) {
                    print("Pressed Like")
                }
                SystemButton(b_name: "arrow.2.squarepath", b_content: "\(data.shares ?? 0.0)", color: font_color, haveBG:false, bgcolor: font_color) {
                    print("Pressed Share")
                }
                Spacer()
                if let sentiment = data.sentiment{
                    let color = sentiment > 3 ? Color.green : sentiment < 3 ? Color.red : Color.gray
                    let emoji = sentiment > 3 ? "😁" : sentiment < 3 ? "😓" : "😐"
                    HStack(alignment: .center, spacing: 2.5) {
                        MainText(content: "\(emoji) ", fontSize: 12,color: .white)
                        MainText(content: String(format: "%.1f", sentiment), fontSize: 12, color: .white)
                    }.padding(7.5)
                    .padding(.horizontal,2.5)
                    .background(color.overlay(BlurView(style: .systemThinMaterial)))
                    .clipShape(Capsule())
                    
                }
            }.frame(width: w, height: h, alignment: .leading)
            
        )
    }
}

//struct PostCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PostCard()
//    }
//}
