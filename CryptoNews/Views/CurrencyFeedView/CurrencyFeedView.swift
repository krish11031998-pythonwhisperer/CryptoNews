//
//  CurrencyFeedView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/10/2021.
//

import SwiftUI

struct CurrencyFeedView: View {
    var currency_data:[CoinMarketData]
    var currency_feed_data:[AssetNewsData]
    var reload: () -> Void
    var heading:String
    var type:FeedPageType
    @Binding var currency:String
    
    
    init(heading:String,type:FeedPageType,currency:Binding<String>,feedData:[AssetNewsData],currencyData:[CoinMarketData],reload: @escaping () -> Void){
        self.heading = heading
        self.type = type
        self._currency = currency
        self.currency_feed_data = feedData
        self.currency_data = currencyData
        self.reload = reload
    }
    
    func handleCurrencyChange(_ newCurrency:CrybseCoinSpotPrice?){
        if let sym = newCurrency?.Currency{
            setWithAnimation {
                self.currency = sym
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: self.heading, width: totalWidth) { w in
                CurrencyCardView(width: w)
                    .onPreferenceChange(CurrencySelectorPreference.self, perform: self.handleCurrencyChange(_:))
                CurrencyFeedPage(w: w, symbol: currency, data: self.currency_feed_data, type: self.type, reload: self.reload)
                    .padding(.top,10)
            }
        }
        .padding(.top,30)
    }
}


extension CurrencyFeedView{
    @ViewBuilder func bg(condition:Bool) -> some View{
        if condition{
            Color.mainBGColor.opacity(0.5)
        }else{
            BlurView(style: .systemThinMaterialDark)
        }
    }
    
}

