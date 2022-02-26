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
            AllAssetView().asyncContainer()
            LatestRedditPost(currencies: self.currencies).asyncContainer()
            LatestTweets(header: "Trending Tweets", currencies: self.currencies, type: .Chronological, limit: 20).asyncContainer()
            NewsSectionMain(currencies: self.currencies, limit: 10,cardHeight: totalHeight * 0.45).asyncContainer()
            Spacer(minLength: 200)
//            CurrencyPriceSummaryViewPreviewProvider()
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
    func CryptoMarketGen(heading:String,srt:String,order:Order = .desc,leadingPadding:Bool = false,cardSize:CGSize = CardSize.slender) -> some View{
        AsyncContainer(size: CardSize.slender) {
            CryptoMarket(heading: heading, srt: srt,order: order,cardSize:cardSize, leadingPadding: leadingPadding)
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
