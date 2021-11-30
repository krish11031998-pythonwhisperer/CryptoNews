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
//            LazyVStack(alignment: .leading, spacing: 10){
            Spacer().frame(height: 50)
            self.trackedAsset
            CryptoMarketGen(heading: "Popular Coins", srt: "d", order: .desc, leadingPadding: true)
            CryptoMarketGen(heading: "Biggest Gainer", srt: "pc", order: .desc, cardSize: CardSize.small)
            CryptoMarketGen(heading: "Biggest Losers", srt: "pc", order: .incr, cardSize: CardSize.small)
            AsyncContainer(size: .zero) {
                LatestTweets(header:"Trending Tweets",currency: "all",type:.Influential,limit: 10)
            }
            
            self.CurrencyFeed
            Spacer(minLength: 200)
//            }
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

    @ViewBuilder var trackedAsset:some View{
        if self.context.selectedCurrency == nil{
            TrackedAssetView(asset: currencies)
        }else{
            Color.clear.frame(width: totalWidth * 0.5, height: totalHeight * 0.4, alignment: .center)
        }
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
        Container(heading: "\(currency) Latest Feed", width: totalWidth, ignoreSides: true) { _ in
            NewsSectionMain(currency: currency).padding(.vertical,10)
            LatestTweets(currency: currency,type: .Influential)
        }
    }
    
    var CurrencyFeed:some View{
        return Group{
            ForEach(self.currencies,id:\.self) {currency in
                AsyncContainer(size: .zero) {
                    self.CurrencyFeedEl(currency)
                        .padding(.vertical,15)
                }
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
