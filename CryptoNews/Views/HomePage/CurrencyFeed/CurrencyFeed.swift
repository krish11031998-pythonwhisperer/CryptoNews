//
//  CurrencyFeed.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/12/2021.
//

import SwiftUI

struct CurrencyFeed: View {
    @EnvironmentObject var context:ContextData
    @State var currencyIdx:Int = 1
    
    var body: some View {
        ForEach(Array(currencies.enumerated()), id:\.offset) { _currency in
            self.CurrencyFeedEl(_currency.element)
        }
    }
}

extension CurrencyFeed{
    
    var currencies:[String]{
        return self.context.user.user?.watching ?? ["MANA","XRP","LTC","BTC"]
    }
    
    var stopLoading:Bool{
        return self.currencyIdx == self.currencies.count - 1
    }
    
    @ViewBuilder func CurrencyFeedEl( _ data: Any) -> some View{
        if let currency = data as? String{
            AsyncContainer(size: .init(width: totalWidth, height: totalHeight)) {
                Container(heading: "\(currency) Latest Feed", width: totalWidth, ignoreSides: true) { _ in
                    NewsSectionMain(currency: currency).padding(.vertical,10)
                    LatestTweets(currency: currency,type: .Influential)
                }
            }.frame(width: totalWidth, height: totalHeight * 1.25, alignment: .center)
            
        }else{
            Color.clear.frame(width: totalWidth, height: totalHeight * 1.25, alignment: .center)
        }
    }

    
    @ViewBuilder func CurrencyFeedEl( _ currency: String) -> some View{
//        AsyncContainer(size: .init(width: totalWidth, height: totalHeight)) {
            Container(heading: "\(currency) Latest Feed", width: totalWidth, ignoreSides: true) { _ in
                NewsSectionMain(currency: currency).padding(.vertical,10)
                LatestTweets(currency: currency,type: .Influential)
            }
//        }
    }
    
    func updateFeed(){
        if self.currencyIdx + 1 <= self.currencies.count - 1{
            self.currencyIdx += 1
        }
    }
    
}

struct CurrencyFeed_Previews: PreviewProvider {
    
    static var context:ContextData = .init()
    
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CurrencyFeed()
                .environmentObject(CurrencyFeed_Previews.context)
        }.background(Color.mainBGColor)
            .ignoresSafeArea()
    }
}
