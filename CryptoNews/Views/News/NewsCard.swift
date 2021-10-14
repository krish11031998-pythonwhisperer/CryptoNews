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
    
    func onEnded(value:DragGesture.Value){
        let location = value.location
        var value = 0
        if location.x >= self.size.width * 0.75{
            value = 1
        }else if location.x <= self.size.width * 0.25{
            value = -1
        }
        self.tapHandler?(value)
    }
    
    var body: some View {
        GeometryReader{g in
            let size = g.frame(in: .local).size
            
            VStack(alignment: .leading, spacing: 5) {
                ImageView(url: self.news.thumbnail,width: size.width, height: size.height * 0.75, contentMode: .fill, alignment: .center)
                self.newsView(size: .init(width: size.width, height: size.height * 0.25 - 5))
            }
            
        }.frame(width: size.width, height: size.height, alignment: .topLeading)
            .background(BlurView(style: .systemThinMaterialDark))
        .clipContent(clipping: .roundClipping)
        .defaultShadow()
        .gesture(DragGesture(minimumDistance: 0).onEnded(self.onEnded(value:)))
        
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
    
    var nextCircle:some View{
        HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "chevron.left") {}
            .opacity(0.2)
            Spacer()
            SystemButton(b_name: "chevron.right") {}
            .opacity(0.2)
        }.padding()
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
    var actionCenter:some View{
        VStack(alignment: .center, spacing: 0) {
            self.nextCircle
            Spacer()
        }
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
        GeometryReader{g in
            let _size = g.frame(in: .local).size
            ZStack(alignment: .center) {
                ForEach(Array(self.newsFeed.FeedData.enumerated()), id: \.offset) { _newsFeed in
                    let news = _newsFeed.element
                    let idx = _newsFeed.offset
                    if idx == self.idx{
                        NewsCard(news: news,size: _size,tapHandler: tapFunction(value:))
                            .overlay(self.actionCenter)
                            .zoomInOut()
                    }
                }
            }.frame(width: _size.width, height: _size.height,alignment: .center)
        }.padding(.all,10)
        .frame(width: size.width, height: size.height, alignment: .center)
        .onAppear(perform: self.onAppear)
    }
    
}

struct NewsCard_Previews: PreviewProvider {
    static var previews: some View {
        NewsCardCarousel(currency: ["LTC"])
            .background(Color.black)
//            .animation(.easeInOut)
    }
}
