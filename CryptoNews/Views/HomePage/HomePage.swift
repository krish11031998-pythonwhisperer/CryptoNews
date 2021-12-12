//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var context:ContextData
    var activeCurrency:Bool{
        return self.context.selectedCurrency != nil
    }
    
    var currencies:[String]{
        return self.context.user.user?.watching ?? ["BTC","LTC","ETH","XRP"]
    }
    
    
    var mainView:some View{
        ScrollView(.vertical,showsIndicators:false){
            Spacer().frame(height: 50)
            if self.context.trackedAssets.count > 0{
                self.trackedAssetView
            }
            
            if self.context.watchedAssets.count > 0{
                self.watchedAssetView
            }
            
            CryptoMarketGen(heading: "Popular Coins", srt: "d", order: .desc, leadingPadding: true)
            CryptoMarketGen(heading: "Biggest Gainer", srt: "pc", order: .desc, cardSize: CardSize.small)
            CryptoMarketGen(heading: "Biggest Losers", srt: "pc", order: .incr, cardSize: CardSize.small)
//            LatestTweets(header:"Trending Tweets",currency: "all",type:.Influential,limit: 10)
            CurrencyFeed()
            Spacer(minLength: 200)
        }.zIndex(1)
    }
    
    var body: some View {
        ZStack(alignment: .center){
            self.mainView
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}

extension HomePage{

    @ViewBuilder var trackedAssetView:some View{
        TrackedAssetView(asset: self.context.trackedAssets)
    }
    
    
    var watchedAssetView:some View{
        WatchedAssets(currencies: self.context.watchedAssets)
    }
    
    func CryptoMarketGen(heading:String,srt:String,order:Order = .desc,leadingPadding:Bool = false,cardSize:CGSize = CardSize.slender) -> some View{
        AsyncContainer(size: .zero) {
            CryptoMarket(heading: heading, srt: srt,order: order,cardSize:cardSize, leadingPadding: leadingPadding)
        }
    }
    
    
    var showMainView:Bool {
        return self.context.selectedNews == nil && self.context.selectedCurrency == nil
    }
    
    @ViewBuilder func CurrencyFeedEl( _ currency: String) -> some View{
        AsyncContainer(size: CardSize.slender) {
            Container(heading: "\(currency) Latest Feed", width: totalWidth, ignoreSides: true) { _ in
                NewsSectionMain(currency: currency).padding(.vertical,10)
                LatestTweets(currency: currency,type: .Influential)
            }
        }
    }
    
}

struct HomePage_Previews: PreviewProvider {
    @StateObject static var context:ContextData = .init()
    static var previews: some View {
        HomePage()
            .environmentObject(HomePage_Previews.context)
            .background(Color.mainBGColor.ignoresSafeArea())
    }
}
