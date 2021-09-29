//
//  NewsCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/09/2021.
//

import SwiftUI

struct NewsCard: View {
    var news:AssetNewsData
    var size:CGSize
    init(news:AssetNewsData,size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.5)){
        self.news = news
        self.size = size
    }
    
    func newsView(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        return VStack(alignment: .leading, spacing: 10) {
            MainText(content: self.news.publisher ?? "News Published", fontSize: 13, color: .white, fontWeight: .semibold)
            MainText(content: self.news.title ?? "News Title", fontSize: 16, color: .white, fontWeight: .regular)
        }.padding(10).frame(width: w, height: h, alignment: .topLeading)
    }
    
    var body: some View {
        GeometryReader{g in
            let size = g.frame(in: .local).size
            
            VStack(alignment: .leading, spacing: 5) {
                ImageView(url: self.news.thumbnail,width: size.width, height: size.height * 0.75, contentMode: .fill, alignment: .center)
                self.newsView(size: .init(width: size.width, height: size.height * 0.25 - 5))
            }
            
        }.frame(width: size.width, height: size.height, alignment: .center)
            .background(BlurView(style: .systemThinMaterialDark))
        .clipContent(clipping: .roundClipping)
        .defaultShadow()
    }
}

struct NewsCardCarousel:View{
    @StateObject var newsFeed:FeedAPI
    @State var idx:Int = 0
    @State var time:Int = 0
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
            SystemButton(b_name: "chevron.left") {self.updateIdx(val: -1)}
            Spacer()
            SystemButton(b_name: "chevron.right") {self.updateIdx(val: 1)}
        }.padding()
    }
    
    var actionCenter:some View{
        VStack(alignment: .center, spacing: 0) {
            self.nextCircle
            Spacer()
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
                        NewsCard(news: news,size: _size)
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
