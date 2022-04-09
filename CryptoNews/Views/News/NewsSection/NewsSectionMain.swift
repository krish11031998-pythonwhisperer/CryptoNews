//
//  NewsSectionMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/11/2021.
//

import SwiftUI

struct NewsSectionMain: View {
    @EnvironmentObject var context:ContextData
//    @StateObject var newsFeed:FeedAPI
    @StateObject var newsAPI:CrybseNewsAPI
    var cardHeight:CGFloat
    
    init(currency:String? = nil,currencies:[String]? = nil,limit:Int = 10,cardHeight:CGFloat = 450){
//        self._newsFeed = .init(wrappedValue: .init(currency: currencies ?? [currency ?? "BTC"], sources: ["news"], type: .Chronological, limit: limit, page: 0))
        self._newsAPI = .init(wrappedValue: .init(tickers: currencies?.reduce("", {$0 != "" ? $0 + "," + $1 : $1})))
        self.cardHeight = cardHeight
    }
    
    var data:CrybseNewsList{
        return self.newsAPI.newsList ?? []
    }
    
    func onAppear(){
        if self.data.isEmpty{
            self.newsAPI.getNews()
        }
    }
    
    func autoTimedCards(w:CGFloat) -> some View{
        let feed = self.data.count > 3 ? Array(self.data[0...2]) : self.data
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 15){
                ForEach(Array(feed.enumerated()),id:\.offset){ _feed in
                    self.autoTimeCardViewGen(_feed.element, width: w)
                        .padding(.leading,_feed.offset == 0 ? 15 : 0)
                        .padding(.trailing, _feed.offset == feed.count - 1 ? 15 : 0)
                }
            }
        }
    }
    
    func onTapHandler(data:CrybseNews){
        self.context.selectedLink = URL(string: data.NewsURL)
    }
    
    func onTapHandle(_ idx:Int){
        if idx >= 0 && idx < self.data.count{
            let data = self.data[idx]
            if context.selectedLink?.absoluteString != data.news_url{
                self.context.selectedLink = URL(string: data.news_url ?? "")
            }
        }
    }
    
    @ViewBuilder func autoTimeCardViewGen(_ data:Any,width:CGFloat) -> some View{
        if let data = data as? CrybseNews{
            NewsCard(news: data, size: .init(width: width * 0.75, height: self.cardHeight))
                .buttonify {
                    self.onTapHandler(data: data)
                }
                .motionModifiedView(axis: .vertical, modifier: .zoomInOut)
                .frame(width: width * 0.75, height: self.cardHeight, alignment: .topLeading)
        }else{
            Color.clear.frame(width: totalWidth, height: 100, alignment: .center)
        }
    }
    
    func slenderCards(w width:CGFloat) -> some View{
        Container(width:width,ignoreSides: false,orientation: .horizontal){ w in
            ForEach(Array(self.data[(self.data.count - 2)...].enumerated()),id:\.offset){ _data in
                let data = _data.element
                NewsCard(news: data, size: .init(width: w * 0.5, height: self.cardHeight * 0.75))
                    .buttonify {
                        self.onTapHandler(data: data)
                    }
            }
        }
    }
    
    var moreCards:some View{
        let data = self.data.count < 4 ? self.data : Array(self.data[3...4])
        return ForEach(Array(data.enumerated()), id:\.offset) { _data in
            let news = _data.element
            
            NewsStandCard(news: news)
        }.frame(width: totalWidth, alignment: .center)
    }
    
    
    @ViewBuilder var innerBody:some View{
        if !self.data.isEmpty{
            Container(heading: "News Highlights",ignoreSides: true) { w in
                self.autoTimedCards(w: w)
                self.slenderCards(w: w)
            }
        }else if self.newsAPI.loading{
            ProgressView()
                .frame(width: totalWidth, alignment: .center)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    var body: some View {
        self.innerBody
            .onAppear(perform: self.onAppear)
    }
}

struct NewsSectionMain_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            NewsSectionMain()
                .padding(.vertical)
                
        }.background(Color.black.ignoresSafeArea())
    }
}
