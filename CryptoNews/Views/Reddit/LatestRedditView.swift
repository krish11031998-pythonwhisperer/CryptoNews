//
//  LatestRedditView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/08/2021.
//

import SwiftUI

struct LatestRedditView: View {
    @StateObject var RedditAPI:FeedAPI
    let font_color:Color = .black
    init(currency:String = "all"){
        self._RedditAPI = .init(wrappedValue: .init(currency: currency == "all" ? ["BTC","LTC","DOGE"] : [currency],sources:["reddit"], type: .Chronological,limit: 50))
    }
    
    func onAppear(){
        if self.RedditAPI.FeedData.isEmpty{
            self.RedditAPI.getAssetInfo()
        }
    }
//
    func redditView(data:Any,size:CGSize) -> AnyView{
        let view = AnyView(Color.black.opacity(0.5).frame(width: size.width, height: size.height, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10)))
        guard let data = data as? AssetNewsData else {return view}
        return AnyView(PostCard(cardType: .Reddit, data: data, size: size,const_size: true))
    }
    
    
    var body: some View {
        Container(heading: "Trending Reddit") { w in
            return AnyView(
                ZStack(alignment: .center) {
                    if self.RedditAPI.FeedData.isEmpty{
                        ProgressView()
                    }else{
                        AutoTimeCardsView(data: self.RedditAPI.FeedData.compactMap({$0.subreddit == nil && $0.body == nil ? nil : $0}),size: .init(width: w , height: totalHeight * 0.4),view: self.redditView(data:size:))
                    }
                }
            )
        }.onAppear(perform: self.onAppear)
    }
}

