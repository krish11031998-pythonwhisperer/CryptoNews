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


struct TwitterPostCard: View {
    
    @EnvironmentObject var context:ContextData
    var cardType:PostCardType
    var data:CrybseTweet
    var size:CGSize
    var font_color:Color
    var const_size:Bool
    var isButton:Bool
    var bg:PostCardBG
    
    init(cardType:PostCardType,data:CrybseTweet,size:CGSize,bg:PostCardBG = .dark,font_color:Color? = nil,const_size:Bool = false,isButton:Bool = true){
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
        Container(width:self.size.width,verticalPadding: 15,spacing:10){ w in
            self.Header(width:w)
            self.Body(w: w)
            if self.height >= totalHeight * 0.35,let image = self.data.media?.first?.url{
                ImageView(url: image, width: w, height: self.height * 0.45 - 10, contentMode: .fill, alignment: .center, clipping: .roundClipping)
            }
            if self.const_size{
                Spacer(minLength: 0)
            }
            self.Footer(width: w)
        }
        .basicCard(size:self.const_size ? self.size : .zero,background: AnyView(self.bgView))
    }

    
    var body: some View {
        if self.data.text != nil{
            if self.isButton{
                self.card
                    .buttonify {
                        if self.context.selectedTweet != self.data{
                            self.context.selectedTweet = self.data
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

extension TwitterPostCard{
    
    var height:CGFloat{
        return self.size.height - 30
    }
    
    @ViewBuilder func Header(width w:CGFloat) -> some View{
        if let user = self.data.user{
            HStack(alignment: .center, spacing: 15) {
                ImageView(url: user.profile_image_url, width: 30, height: 30, contentMode: .fill, alignment: .center)
                    .clipContent(clipping: .circleClipping)
                MainSubHeading(heading: "@\(user.username ?? "Tweet")", subHeading:data.CreatedAt, headingSize: 12.5, subHeadingSize: 10, headColor: self.font_color, subHeadColor: .gray, headingWeight: .semibold, bodyWeight: .regular, alignment: .leading)
                Spacer()
            }
            .frame(width: w, alignment: .topLeading)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }

    @ViewBuilder func Footer(width w:CGFloat) -> some View{
        VStack(alignment: .center, spacing: 5){
            Divider().frame(width: w,height:5, alignment: .center)
            HStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "suit.heart", b_content: "\(data.Like)", color: font_color, haveBG:false,bgcolor: font_color) {
                    print("Pressed Like")
                }
                SystemButton(b_name: "arrow.2.squarepath", b_content: "\(data.Retweet)", color: font_color, haveBG:false, bgcolor: font_color) {
                    print("Pressed Share")
                }
                Spacer()
                self.sentimentView
            }
        }
        .frame(width: w, alignment: .leading)
    }
    
    @ViewBuilder var sentimentView:some View{
        let color = self.data.Sentiment > 3 ? Color.green : self.data.Sentiment < 3 ? Color.red : Color.gray
        let emoji = self.data.Sentiment > 3 ? "😁" : self.data.Sentiment < 3 ? "😓" : "😐"
        HStack(alignment: .center, spacing: 2.5) {
            MainText(content: "\(emoji) ", fontSize: 12,color: self.font_color)
            MainText(content: String(format: "%.1f", self.data.Sentiment), fontSize: 12, color: .white,fontWeight: .semibold)
        }.padding(7.5)
            .padding(.horizontal,2.5)
            .background(color.overlay(BlurView(style: .systemThinMaterial)))
            .clipShape(Capsule())
    }
    
    @ViewBuilder func Body(w:CGFloat,h:CGFloat = .zero) -> some View{
        
        let textView = MainText(content: self.data.Text, fontSize: 14, color: self.font_color,fontWeight: .regular,style: .heading)
            .multilineTextAlignment(.leading)
        
        textView
        
    }
}

//struct PostCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PostCard()
//    }
//}
