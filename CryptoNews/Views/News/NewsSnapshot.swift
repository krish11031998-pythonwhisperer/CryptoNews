//
//  NewsSnapshot.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/04/2022.
//

import SwiftUI

struct NewsSnapshot: View {
    var news:CrybseNews
    var width:CGFloat
    var height:CGFloat
    
    
    init(news:CrybseNews,width:CGFloat,height:CGFloat? = nil){
        self.news = news
        self.width = width
        self.height = height ?? .zero
    }
    
    
    @ViewBuilder func headerView(w:CGFloat) -> some View{
        //        HStack(alignment: .top, spacing: 0) {
        if let title = self.news.title,let publisher  = self.news.source_name{
            Container(width:w,horizontalPadding: 2.5,verticalPadding: 0,spacing: 5) { w in
                MainText(content: publisher.uppercased(), fontSize: 15, color: .gray, fontWeight: .semibold)
                MainText(content: title, fontSize: 17.5, color: .white, fontWeight: .medium)
            }
        }
        //        }.frame(width: w, alignment: .leading)
    }
    
    @ViewBuilder func imgView(w:CGFloat) -> some View{
        if let img = self.news.image_url{
            ImageView(url: img, width: w, height: totalHeight * 0.125, contentMode: .fill, alignment: .center,clipping: .roundCornerMedium)
                .overlay(ZStack(alignment: .center) {
                        if let type = self.news.type,type == "Video"{
                            SystemButton(b_name: "play", color: .white, size: .init(width: 7.5, height: 7.5)){}
                        }else{
                            Color.clear
                        }
                    }
                )
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    
    @ViewBuilder func footer(w:CGFloat) -> some View{
        
        if let sentiment = self.news.sentiment{
            let color:Color = sentiment.lowercased() == "positive" ? .green : sentiment.lowercased() == "negative" ? .red : .white.opacity(0.75)
            MainText(content: sentiment, fontSize: 13.5, color: color, fontWeight: .medium,padding: 7.5)
                .basicCard(background: color.overlay(BlurView.thinLightBlur).opacity(0.45).anyViewWrapper())
                .borderCard(color: color, clipping: .roundClipping)
                .frame(width: w, alignment: .trailing)
        }
    }
    
    var body: some View {
        Container(width:self.width,horizontalPadding: 0,verticalPadding: 3.5,orientation:.horizontal,alignment: .topLeading,spacing: 10){inner_w in
            self.headerView(w: inner_w * 0.65 - 10)
            self.imgView(w: inner_w * 0.35)
        }
    }
}
