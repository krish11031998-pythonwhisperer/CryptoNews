//
//  NewsCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/09/2021.
//

import SwiftUI

struct NewsCard: View {
    var news:CrybseNews
    var tapHandler:((Int) -> Void)?
    var size:CGSize
    init(news:CrybseNews,size:CGSize = .init(width: totalWidth * 0.3, height: totalHeight * 0.5),tapHandler: ((Int) -> Void)? = nil){
        self.news = news
        self.size = size
        self.tapHandler = tapHandler
    }
    
    func footer(w:CGFloat,h:CGFloat) -> some View{
        return VStack(spacing:10){
            RoundedRectangle(cornerRadius: 15)
                .frame(width: w, height: 1, alignment: .center)
                .foregroundColor(.gray)
                .padding(.top,5)
            HStack(alignment: .center, spacing: 5) {
                if let date = self.news.date{
                    MainText(content: date, fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
                }
                Spacer()
                SystemButton(b_name: "circle.grid.2x2", color: .white) {
                    print("Hi")
                }
            }.frame(width: w, alignment: .top)
        }.frame(width: w, height: h, alignment: .center)
    }
    
    func newsView(size:CGSize) -> some View{
            let w = size.width - 20
            let publisher = self.news.source_name ?? "News Publisher"
            let title =  self.news.title ?? "News Publisher"
            
            return VStack(alignment: .leading, spacing: 5) {
                Spacer()
                MainTextSubHeading(heading: publisher, subHeading: title, headingSize: 13, subHeadingSize: 15, headingFont: .normal, subHeadingFont: .normal)
                    .lineLimit(3)
                self.footer(w: w, h: 50)
            }.padding(10)
    }
        
    func buttonArea(w:CGFloat,h:CGFloat,alignment:Alignment = .center,innerView: () -> AnyView,handler: (() -> Void)? = nil) -> some View{
        VStack(alignment: .leading) {
            Spacer()
            innerView()
            Spacer()
        }
        .padding(.horizontal,2.5)
        .frame(width: w,height: h, alignment: alignment)
        .clipContent(clipping: .clipped)
    }

    @ViewBuilder var mainBody:some View{
        if self.size.height < totalHeight * 0.4{
            let h = size.height
            let w = size.width
            ZStack(alignment: .bottom) {
                ImageView(url: self.news.ImageURL,width: w, height: h, contentMode: .fill, alignment: .center)
                self.newsView(size: .init(width: w, height: h))
                    .frame(width: size.width, height: size.height, alignment: .bottomLeading)
                    .background(Color.darkGradColor.opacity(0.5).frame(height: h * 0.5,alignment: .bottom),alignment: .bottom)
            }.frame(width: size.width, height: size.height, alignment: .topLeading)
            
        }else{
            let img_h = size.height * 0.6
            let news_h = size.height * 0.4 - 5
            VStack(alignment: .leading, spacing: 5) {
                ImageView(url: self.news.ImageURL,width: size.width, height: img_h, contentMode: .fill, alignment: .center)
                self.newsView(size: .init(width: size.width, height: news_h))
                    .frame(width: size.width, height: news_h, alignment: .topLeading)
            }.frame(width: size.width, height: size.height, alignment: .topLeading)
        }
    }
    
    var body: some View {
        self.mainBody
            .background(BlurView(style: .systemThinMaterialDark))
            .clipContent(clipping: .roundClipping)
            .defaultShadow()
    }
}
