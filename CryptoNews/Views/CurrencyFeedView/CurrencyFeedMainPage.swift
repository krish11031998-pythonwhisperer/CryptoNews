//
//  FeedMainPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct CurrencyFeedMainPage: View {
    @State var currency:String = "BTC"
    @StateObject var assetAPI:FeedAPI
    @StateObject var MAPI:MarketAPI
    var type:FeedPageType
    
    init(type:FeedPageType){
        self.type = type
        self._assetAPI = .init(wrappedValue: .init(currency: ["BTC"], sources: type == .feed ? ["twitter"] : type == .reddit ? ["reddit"] : ["news"]))
        self._MAPI = .init(wrappedValue: .init(sort: "d",limit: 100,order: .desc))
    }
    
    var heading:String{
        switch self.type{
            case .feed:
                return "Feed"
            case .reddit:
                return "Reddit"
            case .news:
                return "News"
        }
    }
    
    
    
    var body: some View {
        CurrencyFeedView(heading:self.heading, type: self.type,currency: $currency, feedData: self.assetAPI.FeedData, currencyData: self.MAPI.data, reload: self.assetAPI.getNextPage)
        .onAppear(perform: self.onAppear)
        .onChange(of: self.currency) { newCurr in
            self.assetAPI.fetchNewCurrency(currency: newCurr)
        }
    }
}


extension CurrencyFeedMainPage{
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if self.assetAPI.FeedData.isEmpty{
                self.assetAPI.getAssetInfo()
            }
            
            if self.MAPI.data.isEmpty{
                self.MAPI.getMarketData()
            }
        }
    }
}

struct FeedMainPage_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyFeedMainPage(type: .feed)
            .background(Color.mainBGColor)
            .edgesIgnoringSafeArea(.all)
            
            
    }
}
