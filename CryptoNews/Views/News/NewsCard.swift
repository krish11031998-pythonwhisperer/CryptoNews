//
//  NewsCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/09/2021.
//

import SwiftUI

struct NewsCard: View {
    var news:AssetNewsData
    var tapHandler:((Int) -> Void)?
    var size:CGSize
    init(news:AssetNewsData,size:CGSize = .init(width: totalWidth * 0.3, height: totalHeight * 0.5),tapHandler: ((Int) -> Void)? = nil){
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
                MainText(content: self.news.date.stringDate(), fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
                Spacer()
                SystemButton(b_name: "circle.grid.2x2", color: .white) {
                    print("Hi")
                }
            }.frame(width: w, alignment: .top)
        }.frame(width: w, height: h, alignment: .center)
    }
    
    func newsView(size:CGSize) -> some View{
            let w = size.width - 20
            let h = size.height - 10
            let publisher = self.news.publisher ?? "News Publisher"

            let title =  self.news.title ?? "News Publisher"
            let text_h = h - 60
            let linelimit = Int(floor(text_h/16) - 2)
            
            return VStack(alignment: .leading, spacing: 5) {
                MainSubHeading(heading: publisher, subHeading: title, headingSize: 13, subHeadingSize: linelimit <= 0 ? 13 : 16, headingFont: .normal, subHeadingFont: .normal).fixedSize(horizontal: false, vertical: true)
                    .lineLimit(linelimit)
                    .frame(width: w,height: text_h,alignment: .topLeading)
                self.footer(w: w, h: 50)
                    .padding(.bottom,5)
            }.padding(.horizontal,10)
            .padding(.vertical,5)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
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
//        .onTapGesture {
//            handler?()
//        }
    }
    
//    func iteratingButton(w:CGFloat,h:CGFloat) -> some View{
//        HStack(alignment: .center, spacing: 0) {
//            self.buttonArea(w: w * 0.25,h: h,alignment: .leading,innerView: {
//                AnyView(SystemButton(b_name: "chevron.left") {})
//            }) {
//                withAnimation(.easeInOut) {
//                    self.tapHandler?(-1)
//                }
//            }
//            self.buttonArea(w: w * 0.5,h: h,innerView: {
//                AnyView(Color.clear.opacity(0.5))
//            }){
//                withAnimation(.easeInOut) {
//                    self.tapHandler?(0)
//                }
//            }
//            self.buttonArea(w: w * 0.25,h: h,alignment: .trailing,innerView: {
//                AnyView(SystemButton(b_name: "chevron.right") {})
//            }){
//                withAnimation(.easeInOut) {
//                    self.tapHandler?(1)
//                }
//            }
//        }
//        .frame(width: w, height: h, alignment: .center)
//    }
    
    @ViewBuilder var mainBody:some View{
        if self.size.height < totalHeight * 0.4{
            let h = size.height
            let w = size.width
            ZStack(alignment: .bottom) {
                ImageView(url: self.news.thumbnail,width: w, height: h, contentMode: .fill, alignment: .center)
//                if let _ = self.tapHandler{
//                    self.iteratingButton(w: w, h: h)
//                }
                self.newsView(size: .init(width: w, height: h * 0.5))
                    .background(Color.darkGradColor.opacity(0.5).frame(height: h * 0.5))
            }.frame(width: size.width, height: size.height, alignment: .topLeading)
                
        }else{
                let img_h = size.height * 0.7
                let news_h = size.height * 0.3 - 5
                VStack(alignment: .leading, spacing: 5) {
                    ZStack(alignment: .center) {
                        ImageView(url: self.news.thumbnail,width: size.width, height: img_h, contentMode: .fill, alignment: .center)
//                        if let _ = self.tapHandler{
//                            self.iteratingButton(w: size.width, h: img_h)
//                        }
                    }.frame(width: size.width, height: img_h, alignment: .center)
                    self.newsView(size: .init(width: size.width, height: news_h))
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

struct NewsCardCarousel:View{
    @StateObject var newsFeed:FeedAPI
    @State var idx:Int = 0
    @State var time:Int = 0
    @EnvironmentObject var context:ContextData
    let timeLimit:Int = 30
    var size:CGSize
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    init(currency:[String],size:CGSize = .init(width: totalWidth, height: totalHeight * 0.75)){
        self._newsFeed = .init(wrappedValue: .init(currency: currency, sources: ["news"], type: .Chronological, limit: 100, page: 1))
        self.size = size
    }
    
    func onAppear(){
        if self.newsFeed.FeedData.isEmpty{
            self.newsFeed.getAssetInfo()
        }
    }
    
    func onReciveTimer(){
        if self.time == self.timeLimit{
            self.time = 0
            withAnimation(.easeInOut) {
                self.idx += 1
            }
        }else{
            self.time += 1
        }
    }
    
    func updateIdx(val:Int){
        if (val < 0 && self.idx >= 1) || (val > 0 && self.idx < self.newsFeed.FeedData.count - 1){
            withAnimation(.easeInOut){
                self.idx += val
            }
        }
        self.time = 0
    }
        
    func tapFunction(value:Int){
        DispatchQueue.main.async {
            if value == 0{
                self.context.selectedNews = self.newsFeed.FeedData[self.idx]
            }else{
                self.updateIdx(val: value)
            }
        }
    }
    
    var body: some View{
        GeometryReader{g -> AnyView in
            let _size = g.frame(in: .local).size
            let midX = g.frame(in: .global).midX
            
            DispatchQueue.main.async {
                if midX > 0 && midX < totalWidth && self.newsFeed.FeedData.isEmpty{
                    self.onAppear()
                }
            }
            
            
            
            return AnyView(ZStack(alignment: .center) {
                ForEach(Array(self.newsFeed.FeedData.enumerated()), id: \.offset) { _newsFeed in
                    let news = _newsFeed.element
                    let idx = _newsFeed.offset
                    if idx == self.idx{
                        NewsCard(news: news,size: _size,tapHandler: nil)
                            .zoomInOut()
                    }
                }
            }.frame(width: _size.width, height: _size.height,alignment: .center))
        }.padding(.all,10)
        .frame(width: size.width, height: size.height, alignment: .center)
//        .onAppear(perform: self.onAppear)
    }
    
}

struct NewsCard_Previews: PreviewProvider {
    static var previews: some View {
        let cardSize:CGSize = .init(width: totalWidth - 30, height: 450)
        NewsCardCarousel(currency: ["LTC"],size: .init(width: cardSize.width * 0.5 - 5, height: cardSize.height * 0.75))
            .background(Color.black)
    }
}
