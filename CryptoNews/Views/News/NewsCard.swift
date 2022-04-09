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
                MainSubHeading(heading: publisher, subHeading: title, headingSize: 13, subHeadingSize: 15, headingFont: .normal, subHeadingFont: .normal)
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

//struct NewsCardCarousel:View{
//    @StateObject var newsFeed:FeedAPI
//    @State var idx:Int = 0
//    @State var time:Int = 0
//    @EnvironmentObject var context:ContextData
//    let timeLimit:Int = 30
//    var size:CGSize
//    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    init(currency:[String],size:CGSize = .init(width: totalWidth, height: totalHeight * 0.75)){
//        self._newsFeed = .init(wrappedValue: .init(currency: currency, sources: ["news"], type: .Chronological, limit: 100, page: 1))
//        self.size = size
//    }
//
//    func onAppear(){
//        if self.newsFeed.FeedData.isEmpty{
//            self.newsFeed.getAssetInfo()
//        }
//    }
//
//    func onReciveTimer(){
//        if self.time == self.timeLimit{
//            self.time = 0
//            withAnimation(.easeInOut) {
//                self.idx += 1
//            }
//        }else{
//            self.time += 1
//        }
//    }
//
//    func updateIdx(val:Int){
//        if (val < 0 && self.idx >= 1) || (val > 0 && self.idx < self.newsFeed.FeedData.count - 1){
//            withAnimation(.easeInOut){
//                self.idx += val
//            }
//        }
//        self.time = 0
//    }
//
//    func tapFunction(value:Int){
//        DispatchQueue.main.async {
//            if value == 0{
//                self.context.selectedLink = self.newsFeed.FeedData[self.idx].URL
//            }else{
//                self.updateIdx(val: value)
//            }
//        }
//    }
//
//    var body: some View{
//        GeometryReader{g -> AnyView in
//            let _size = g.frame(in: .local).size
//            let midX = g.frame(in: .global).midX
//
//            DispatchQueue.main.async {
//                if midX > 0 && midX < totalWidth && self.newsFeed.FeedData.isEmpty{
//                    self.onAppear()
//                }
//            }
//
//
//
//            return AnyView(ZStack(alignment: .center) {
//                ForEach(Array(self.newsFeed.FeedData.enumerated()), id: \.offset) { _newsFeed in
//                    let news = _newsFeed.element
//                    let idx = _newsFeed.offset
//                    if idx == self.idx{
//                        NewsCard(news: news,size: _size,tapHandler: nil)
//                            .zoomInOut()
//                    }
//                }
//            }.frame(width: _size.width, height: _size.height,alignment: .center))
//        }.padding(.all,10)
//        .frame(width: size.width, height: size.height, alignment: .center)
////        .onAppear(perform: self.onAppear)
//    }
//
//}
//
//struct NewsCard_Previews: PreviewProvider {
//    static var previews: some View {
//        let cardSize:CGSize = .init(width: totalWidth - 30, height: 450)
//        NewsCardCarousel(currency: ["LTC"],size: .init(width: cardSize.width - 30, height: cardSize.height * 1))
//            .background(mainBGView)
//    }
//}
