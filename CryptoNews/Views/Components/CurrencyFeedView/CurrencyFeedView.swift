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
    
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: self.heading, width: totalWidth) { w in
                self.CurrencyView(w: w)
                CurrencyFeedPage(w: w, symbol: currency, data: self.currency_feed_data, type: self.type, reload: self.reload)
                    .padding(.top,10)
            }
        }
        .padding(.top,30)
    }
}


extension CurrencyFeedView{
    
    func CurrencyView(w:CGFloat) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 7.5) {
                ForEach(Array(self.currency_data.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    let curr = data.s ?? "NOC"
                    LazyVStack(alignment: .center, spacing: 5) {
                        CurrencySymbolView(currency: data.s ?? "BTC", size: .medium, width: 30)
                        MainText(content: curr, fontSize: 12, color: .white, fontWeight: .regular, style: .normal)
                    }.padding(10)
                    .aspectRatio(contentMode: .fill)
                    .background(self.bg(condition: curr == currency))
                    .clipContent(clipping: .roundClipping)
                    .buttonify {
                        DispatchQueue.main.async {
                            self.currency = curr
                        }
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder func bg(condition:Bool) -> some View{
        if condition{
            Color.mainBGColor.opacity(0.5)
        }else{
            BlurView(style: .systemThinMaterialDark)
        }
    }
    
}

//struct CurrencyFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyFeedView()
//    }
//}
