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
            if let uid = self.context.user.user?.uid, let currencies = self.context.user.user?.watching{
                AllAssetView(uid:uid, currencies: currencies)
            }
            
            LatestTweets(header:"Trending Tweets",currencies:self.userFavAsset,type:.Influential,limit: 15).asyncContainer(size: .init(width: totalWidth, height: totalHeight))
            CurrencyFeed().asyncContainer(size: .init(width: totalWidth, height: totalHeight))
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
    
    var userFavAsset:[String]{
        return self.context.trackedAssets + self.context.watchedAssets
    }
    
    func CryptoMarketGen(heading:String,srt:String,order:Order = .desc,leadingPadding:Bool = false,cardSize:CGSize = CardSize.slender) -> some View{
        AsyncContainer(size: CardSize.slender) {
            CryptoMarket(heading: heading, srt: srt,order: order,cardSize:cardSize, leadingPadding: leadingPadding)
        }
    }
    
    
    var showMainView:Bool {
        return self.context.selectedNews == nil && self.context.selectedCurrency == nil
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
