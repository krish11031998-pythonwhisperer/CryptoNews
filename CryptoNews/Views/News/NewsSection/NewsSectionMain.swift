//
//  NewsSectionMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/11/2021.
//

import SwiftUI

struct NewsSectionMain: View {
    @EnvironmentObject var context:ContextData
    @StateObject var newsFeed:FeedAPI
    var cardHeight:CGFloat
    
    init(currency:String? = nil,currencies:[String]? = nil,limit:Int = 10,cardHeight:CGFloat = 450){
        self._newsFeed = .init(wrappedValue: .init(currency: currencies ?? [currency ?? "BTC"], sources: ["news"], type: .Chronological, limit: limit, page: 0))
        self.cardHeight = cardHeight
    }
    
    var data:[AssetNewsData]{
        return self.newsFeed.FeedData.filter({$0.Thumbnail != ""})
    }
    
    func onAppear(){
        if self.data.isEmpty{
            self.newsFeed.getAssetInfo()
        }
    }
    
    func autoTimedCards(w:CGFloat) -> some View{
        let feed = self.data.count > 3 ? Array(self.data[0...2]) : self.data
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 15){
                ForEach(Array(feed.enumerated()),id:\.offset){ _feed in
                    self.autoTimeCardViewGen(_feed.element, width: w)
                }
            }
        }
    }
    
    func onTapHandler(data:AssetNewsData){
        self.context.selectedLink = data.URL
    }
    
    func onTapHandle(_ idx:Int){
        if idx >= 0 && idx < self.data.count{
            let data = self.data[idx]
            if context.selectedLink?.absoluteString != data.url{
                self.context.selectedLink = URL(string: data.url ?? "")
            }
        }
    }
    
    @ViewBuilder func autoTimeCardViewGen(_ data:Any,width:CGFloat) -> some View{
        if let data = data as? AssetNewsData{
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
    
    func slenderCards(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data[(self.data.count - 2)...].enumerated()),id:\.offset){ _data in
                let data = _data.element
                
                NewsCard(news: data, size: .init(width: w * 0.5, height: self.cardHeight * 0.75))
                    .buttonify {
                        self.onTapHandler(data: data)
                    }
            }
        }.frame(width: totalWidth, alignment: .center)
    }
    
    var moreCards:some View{
        let data = self.data.count < 4 ? self.data : Array(self.data[3...4])
        return ForEach(Array(data.enumerated()), id:\.offset) { _data in
            let news = _data.element
            
            NewsStandCard(news: news)
        }.frame(width: totalWidth, alignment: .center)
    }
    
    var body: some View {
        Group{
            if !self.data.isEmpty{
                Container(heading: "News Highlights",ignoreSides: true) { w in
                    self.autoTimedCards(w: w)
                    self.slenderCards(w: w  - 30)
                }
            }else if self.newsFeed.loading{
                ProgressView()
                    .frame(width: totalWidth, alignment: .center)
            }else{
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            }
        }.onAppear(perform: self.onAppear)
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
