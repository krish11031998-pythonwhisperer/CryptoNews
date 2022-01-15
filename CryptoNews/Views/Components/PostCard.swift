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
    case News
}

enum PostCardBG{
    case light
    case dark
}


struct PostCard: View {
    @EnvironmentObject var context:ContextData
    var cardType:PostCardType
    var data:AssetNewsData
    var size:CGSize
    var font_color:Color
    var const_size:Bool
    var isButton:Bool
    var bg:PostCardBG
    init(cardType:PostCardType,data:AssetNewsData,size:CGSize,bg:PostCardBG = .dark,font_color:Color? = nil,const_size:Bool = false,isButton:Bool = true){
        self.cardType = cardType
        self.data = data
        self.size = size
        self.bg = bg
        self.font_color = font_color ?? (bg == .dark ? Color.white : Color.black)
        self.const_size = const_size
        self.isButton = isButton
    }
    
    
    @ViewBuilder var bgView:some View{
        if self.bg == .dark{
            mainBGView
        }else{
            mainLightBGView
        }
        
    }
    
    @ViewBuilder func body(w:CGFloat,h:CGFloat) -> some View{
        if self.data.link?.isImgURLStr() ?? false{
            ImageView(url: self.data.link, width: w, height: h * 0.8 - 40, contentMode: .fill, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    VStack(alignment: .leading, spacing: 10){
                        Spacer()
                        self.Body(size: .init(width: w - 20, height: (h * 0.6) - 20))
                    }.padding(10)
                )
        }else{
            self.Body(size: .init(width: w, height: (h * 0.8) - 40))
        }
    }
    
    var card:some View{
        let w = size.width - 20
        let h = size.height - 20
        
        let view =
//        ZStack(alignment: .bottom) {
//            self.bgView
        VStack(alignment: .leading, spacing: 10) {
            self.Header(size: .init(width: w, height: h * 0.1))
            self.body(w: w, h: h)
            Spacer(minLength: 0)
            Divider().frame(width: w, alignment: .center)
            self.Footer(data: data, size: .init(width: w, height: h * 0.1))
        }.padding()
//        }
        .frame(width: size.width, alignment: .center)
        .background(self.bgView)
        .aspectRatio(contentMode: .fill)
        .frame(minHeight: self.const_size ? size.height : 0,maxHeight: self.size.height)
        .clipContent(clipping: .roundClipping)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        
        return view
        
    }
    
    var imageViewCard:some View{
        let w = size.width - 20
        let h = size.height - 20
        let view = ZStack(alignment: .topLeading){
            ImageView(url: self.data.link, width: size.width, contentMode: .fill, alignment: .center,autoHeight: true)
            VStack(alignment: .leading, spacing: 10){
                self.Header(size: .init(width: w, height: h * 0.2))
                Spacer()
                self.Body(size: .init(width: w, height:h * 0.7))
            }.padding(10)
        }.clipShape(RoundedRectangle(cornerRadius: 15))
        
        return view
    }
    
    var body: some View {
        if self.cardType == .Reddit && self.data.link?.isImgURLStr() ?? false{
            self.imageViewCard
        }else if self.data.body != nil || self.data.title != nil{
            if self.isButton{
                self.card
                    .buttonify {
                        withAnimation(.easeInOut) {
                            withAnimation(.easeInOut) {
                                self.context.selectedNews = self.data
                            }
                        }
                    }
            }else{
                self.card
            }
            
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
//        }.springButton()

        
    }
}

extension PostCard{
    func Header(size:CGSize) -> AnyView{
        let w = size.width
        let h = size.height
        return AnyView(
            HStack(alignment: .center, spacing: 15) {
                ImageView(url: data.profile_image, width: h, height: h, contentMode: .fill, alignment: .center)
                    .clipContent(clipping: .circleClipping)
                    .padding(10)
//                    .background(BlurView(style: .light).clipContent(clipping: .circleClipping))
                VStack(alignment: .leading, spacing: 5) {
                    MainText(content: self.cardType == .Reddit ?  "/\(data.subreddit ?? "Subreddit")" : "@\(data.twitter_screen_name ?? "Tweet")", fontSize: 12.5,color: font_color,fontWeight: .semibold)
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
    
    
    func Body(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        
        let (content,_url) = (self.data.body ?? self.data.title ?? "No Text").containsURL()
        let url = _url.first
        
        
        return MainText(content: content, fontSize: 14, color: self.font_color,fontWeight: .regular,style: .heading)
            .multilineTextAlignment(.leading)
            .padding(.vertical,5)
            .frame(width: w, alignment: .leading)
            .frame(maxHeight: h, alignment: .top)
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
                        MainText(content: "\(emoji) ", fontSize: 12,color: self.font_color)
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
