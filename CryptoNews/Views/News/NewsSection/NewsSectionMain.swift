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
//    var currency:String
    
    init(currency:String? = nil,currencies:[String]? = nil,limit:Int = 10){
        self._newsFeed = .init(wrappedValue: .init(currency: currencies ?? [currency ?? "BTC"], sources: ["news"], type: .Chronological, limit: limit, page: 0))
//        self.currency = currency
    }
    
    var data:[AssetNewsData]{
        return self.newsFeed.FeedData
    }
    
    func onAppear(){
//        DispatchQueue.main.async {
        if self.data.isEmpty{
            self.newsFeed.getAssetInfo()
        }
//        }
    }
    var cardSize:CGSize = .init(width: totalWidth - 30, height: 450)
    
    var autoTimedCards:some View{
        let feedView = Array(self.data[..<(self.data.count - 2)]).map({AnyView(autoTimeCardViewGen($0))})
        return CardSlidingView(cardSize: self.cardSize, views: feedView, leading: false,centralize: true )
    }
    
    
    func onTapHandle(_ idx:Int){
        if idx >= 0 && idx < self.data.count{
            let data = self.data[idx]
            if self.context.selectedNews?.lunar_id != data.lunar_id{
                self.context.selectedNews = data
            }
        }
    }
    
    @ViewBuilder func autoTimeCardViewGen(_ data:Any) -> some View{
        if let data = data as? AssetNewsData{
            NewsCard(news: data, size: self.cardSize)
                .buttonify {
                    if self.context.selectedNews?.lunar_id != data.lunar_id{
                        self.context.selectedNews = data
                    }
                }
        }else{
            Color.clear.frame(width: totalWidth, height: 100, alignment: .center)
        }
    }
    
    var slenderCards:some View{
        HStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data[(self.data.count - 2)...].enumerated()),id:\.offset){ _data in
                let data = _data.element
                
                NewsCard(news: data, size: .init(width: self.cardSize.width * 0.5 - 5, height: self.cardSize.height * 0.75))
                    .buttonify {
                        if self.context.selectedNews?.lunar_id != data.lunar_id{
                            self.context.selectedNews = data
                        }
                    }
            }
        }.frame(width: totalWidth, alignment: .center)
    }
    
    var moreCards:some View{
        let data = Array(self.data[(self.data.count - 5)...])
        return ForEach(Array(data.enumerated()), id:\.offset) { _data in
            let news = _data.element
            
            NewsStandCard(news: news)
        }.frame(width: totalWidth, alignment: .center)
    }

    
    var totalFrame:CGSize{
        return .init(width: self.cardSize.width, height: self.cardSize.height * 1.75)
    }
    
    var body: some View {
        if !self.newsFeed.FeedData.isEmpty{
            VStack(alignment: .leading, spacing: 15) {
                self.autoTimedCards
                self.slenderCards
                self.moreCards
            }
            .aspectRatio(contentMode: .fill)
        }else{
            ProgressView()
                .onAppear(perform: self.onAppear)
                .frame(width: totalWidth, height: self.totalFrame.height, alignment: .center)
        }
    }
}

struct NewsSectionMain_Previews: PreviewProvider {
    static var previews: some View {
        NewsSectionMain()
            .aspectRatio(contentMode: .fill)
            .background(Color.blue)
    }
}
