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
    init(news:AssetNewsData,size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.5),tapHandler: ((Int) -> Void)? = nil){
        self.news = news
        self.size = size
        self.tapHandler = tapHandler
    }
    
    func newsView(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        return VStack(alignment: .leading, spacing: 10) {
            MainText(content: self.news.publisher ?? "News Publisher", fontSize: 13, color: .gray, fontWeight: .semibold)
                .lineLimit(1)
            MainText(content: self.news.title ?? "News Title", fontSize: 16, color: .white, fontWeight: .regular)
                .multilineTextAlignment(.leading)
        }.padding(10).frame(width: w, height: h, alignment: .topLeading)
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
        .onTapGesture {
            handler?()
        }
    }
    
    func nextCircle(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 0) {
            self.buttonArea(w: w * 0.25,h: h,alignment: .leading,innerView: {
                AnyView(SystemButton(b_name: "chevron.left") {})
            }) {
                withAnimation(.easeInOut) {
                    self.tapHandler?(-1)
                }
            }
            self.buttonArea(w: w * 0.5,h: h,innerView: {
                AnyView(Color.clear.opacity(0.5))
            }){
                withAnimation(.easeInOut) {
                    self.tapHandler?(0)
                }
            }
            self.buttonArea(w: w * 0.25,h: h,alignment: .trailing,innerView: {
                AnyView(SystemButton(b_name: "chevron.right") {})
            }){
                withAnimation(.easeInOut) {
                    self.tapHandler?(1)
                }
            }
        }
        .frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g in
            let size = g.frame(in: .local).size
            
            VStack(alignment: .leading, spacing: 5) {
                ZStack(alignment: .center) {
                    ImageView(url: self.news.thumbnail,width: size.width, height: size.height * 0.75, contentMode: .fill, alignment: .center)
                    self.nextCircle(w: size.width, h: size.height * 0.75)
                }.frame(width: size.width, height: size.height * 0.75, alignment: .center)
                self.newsView(size: .init(width: size.width, height: size.height * 0.25 - 5))
            }
            
        }.frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(BlurView(style: .systemThinMaterialDark))
        .clipContent(clipping: .roundClipping)
        .defaultShadow()
//        .gesture(DragGesture(minimumDistance: 0).onEnded(self.onEnded(value:)))
        
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
                        NewsCard(news: news,size: _size,tapHandler: tapFunction(value:))
//                            .overlay(self.nextCircle(w: _size.width, h: _size.height))
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
        NewsCardCarousel(currency: ["LTC"])
            .background(Color.black)
//            .animation(.easeInOut)
    }
}
