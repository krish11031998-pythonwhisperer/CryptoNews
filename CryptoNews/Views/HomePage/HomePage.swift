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
        print(self.context.user.user?.watching)
        return self.context.user.user?.watching ?? ["BTC","LTC","ETH","XRP"]
    }
    
    
    var mainView:some View{
        ScrollView(.vertical,showsIndicators:false){
            Spacer().frame(height: 50)
            if self.context.selectedCurrency != nil || self.context.selectedNews != nil || self.context.selectedSymbol != nil{
                Color.clear
                    .frame(width: totalWidth, height: totalHeight * 0.4, alignment: .center)
                    .overlay(ProgressView())
            }else{
                TrackedAssetView(asset: currencies)
            }
            CryptoMarket(heading: "Popular Coins",srt:"d",order:.desc,leadingPadding: true)
            CryptoMarket(heading: "Biggest Gainer", srt: "pc",order: .desc,cardSize: CardSize.small)
            CryptoMarket(heading: "Biggest Losers", srt: "pc",order: .incr,cardSize: CardSize.small)
            LatestTweets(header:"Trending Tweets",currency: "all",type:.Influential,limit: 10)
            self.CurrencyFeed
            Spacer(minLength: 200)
        }.zIndex(1)
    }
    
    var body: some View {
        ZStack(alignment: .center){
            self.mainView
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: self.context.selectedCurrency?.name) { newValue in
            print("Currency choosen is : ",newValue)
        }
    }
}

extension HomePage{

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
                self.CurrencyFeedEl(currency)
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
