//
//  CurrencyInfoView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 24/08/2021.
//

import SwiftUI

struct CurrencyInfoView: View {
    var currency:String
    @StateObject var feedAPI:FeedAPI
    
    init(curr:String){
        self.currency = curr
        self._feedAPI = .init(wrappedValue: .init(currency: [curr], sources: ["twitter","reddit"], type: .Chronological, limit: 20))
    }
    
    func CardView(data:Any,type:PostCardType,size:CGSize) -> AnyView{
        let view = AnyView(Color.black.opacity(0.5).frame(width: size.width, height: size.height, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10)))
        guard let data = data as? AssetNewsData else {return view}
        return AnyView(PostCard(cardType: type, data: data, size: size,const_size: true))
    }
    
    var tweetData:[AssetNewsData]{
        return self.feedAPI.FeedData.compactMap({$0.twitter_screen_name != nil ? $0 : nil})
    }
    
    
    var redditData:[AssetNewsData]{
        return self.feedAPI.FeedData.compactMap({$0.twitter_screen_name == nil ? $0 : nil})
    }
    
    
    func onAppear(){
        if self.feedAPI.FeedData.isEmpty{
            self.feedAPI.getAssetInfo()
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .center, spacing: 10){
                RecentNews(currency: self.currency,size: .init(width: totalWidth, height: totalHeight * 0.75))
                if !self.feedAPI.FeedData.isEmpty{
                    AutoTimeCardsView(data: self.tweetData, size: .init(width: totalWidth * 0.9, height: totalHeight * 0.3)) { data, size in
                        self.CardView(data: data, type: .Tweet, size: size)
                    }
                    AutoTimeCardsView(data: self.redditData, size: .init(width: totalWidth, height: totalHeight * 0.3)) { data, size in
                        self.CardView(data: data, type: .Reddit, size: size)
                    }
                }
            }
            .onAppear(perform:self.onAppear)
        }
    }
}

struct CurrencyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyInfoView(curr: "BTC")
    }
}
