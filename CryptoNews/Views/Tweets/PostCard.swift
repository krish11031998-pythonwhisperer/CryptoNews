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
    case Youtube
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
            BlurView.thinDarkBlur
        }else{
            mainLightBGView
        }
        
    }
    
    @ViewBuilder var card:some View{
        Container(width:self.size.width,verticalPadding: 15){ w in
            self.Header(width:w)
            self.Body(w: w)
            if self.const_size{
                Spacer(minLength: 0)
            }
            self.Footer(width: w)
        }
        .basicCard(size:self.const_size ? self.size : .zero,background: AnyView(self.bgView))
    }

    
    var body: some View {
        if self.data.body != nil || self.data.title != nil{
            if self.isButton{
                self.card
                .buttonify {
                    if let urlStr = self.data.url, let url = URL(string:urlStr){
                        self.context.selectedLink = url
                    }
                }
            }else{
                self.card
            }
            
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
    }
}

extension PostCard{
    
    @ViewBuilder func Header(width w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 15) {
            ImageView(url: data.profile_image, width: 25, height: 25, contentMode: .fill, alignment: .center)
                .clipContent(clipping: .circleClipping)
            MainSubHeading(heading: "@\(data.twitter_screen_name ?? "Tweet")", subHeading: "\(Date(timeIntervalSince1970: .init(data.time ?? 0)).stringDate())", headingSize: 12.5, subHeadingSize: 10, headColor: self.font_color, subHeadColor: .gray, headingWeight: .semibold, bodyWeight: .regular, alignment: .leading)
            Spacer()
            if let currency = data.symbol{
                MainText(content: currency, fontSize: 12,color: .white,fontWeight: .bold)
                    .blobify(color: AnyView(BlurView.thinDarkBlur), clipping: .roundCornerMedium)
            }
        }.frame(width: w, alignment: .topLeading)
        
    }

    @ViewBuilder func Footer(width w:CGFloat) -> some View{
        VStack(alignment: .center, spacing: 10){
            Divider().frame(width: w,height:5, alignment: .center)
            HStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "suit.heart", b_content: "\(data.likes ?? 0)", color: font_color, haveBG:false,bgcolor: font_color) {
                    print("Pressed Like")
                }
                SystemButton(b_name: "arrow.2.squarepath", b_content: "\(data.shares ?? 0.0)", color: font_color, haveBG:false, bgcolor: font_color) {
                    print("Pressed Share")
                }
                Spacer()
                if let sentiment = self.data.sentiment{
                    let color = sentiment > 3 ? Color.green : sentiment < 3 ? Color.red : Color.gray
                    let emoji = sentiment > 3 ? "😁" : sentiment < 3 ? "😓" : "😐"
                    HStack(alignment: .center, spacing: 2.5) {
                        MainText(content: "\(emoji) ", fontSize: 12,color: self.font_color)
                        MainText(content: String(format: "%.1f", sentiment), fontSize: 12, color: .white,fontWeight: .semibold)
                    }.padding(7.5)
                        .padding(.horizontal,2.5)
                        .background(color.overlay(BlurView(style: .systemThinMaterial)))
                        .clipShape(Capsule())
                    
                }
            }
            .frame(width: w, alignment: .leading)
        }
    }
    
    @ViewBuilder func Body(w:CGFloat,h:CGFloat = .zero) -> some View{
        let (content,_) = (self.data.body ?? self.data.title ?? "No Text").containsURL()
        let textView = MainText(content: content, fontSize: 14, color: self.font_color,fontWeight: .regular,style: .heading)
            .multilineTextAlignment(.leading)
        if self.const_size{
            textView
                .truncationMode(.tail)
        }else{
            textView
        }
        
    }
}

//struct PostCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PostCard()
//    }
//}
