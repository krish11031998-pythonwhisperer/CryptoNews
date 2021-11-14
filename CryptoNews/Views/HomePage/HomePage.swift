//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
//    var currencies:[String] = ["BTC","LTC","ETH","XRP"]
//    var color:[String:Color] = ["BTC":Color.orange,"LTC":Color.yellow,"ETH":Color.blue,"XRP":Color.red]
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
            LazyVStack(alignment: .center, spacing: 15) {
                Spacer().frame(height: 50)
                TrackedAssetView(asset: currencies)
                CryptoMarket(heading: "Popular Coins",srt:"d",order:.desc,leadingPadding: true)
                CryptoMarket(heading: "Biggest Gainer", srt: "pc",order: .desc,cardSize: CardSize.small)
                CryptoMarket(heading: "Biggest Losers", srt: "pc",order: .incr,cardSize: CardSize.small)
                LatestTweets(currency: "all")
                self.NewsSection
                
                Spacer(minLength: 200)
            }
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
    
    var NewsSection:some View{
        return RecentNewsCarousel(heading: "News") { currency in
            guard let curr = currency as? String  else {return AnyView(Color.clear)}
            return AnyView(NewsCardCarousel(currency: [curr],size: .init(width: totalWidth, height: totalHeight * 0.65))
            )
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
