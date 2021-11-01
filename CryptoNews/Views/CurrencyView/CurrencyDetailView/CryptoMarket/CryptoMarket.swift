//
//  CryptoMarket.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarket: View {
    @EnvironmentObject var context:ContextData
    @StateObject var MAPI:CGMarketAPI
    var heading:String
    var size:CGSize
    
    
    
    init(heading:String,order:CGMarketOrder = .market_cap_desc,cardSize:CGSize = CardSize.slender){
        self.size = cardSize
        self.heading = heading
        self._MAPI = .init(wrappedValue: .init(vs_currency: "usd",order:order))
    }
    
    func onAppear(){
        if self.MAPI.data.isEmpty{
            self.MAPI.getCoinMarketData()
        }
    }
    
    var view:[AnyView]?{
        if !self.MAPI.data.isEmpty{
            return self.MAPI.data.enumerated().compactMap({self.ViewElement(data: $0.element,idx:$0.offset)})
        }
        
        return nil
    }
    
   func ViewElement(data:CoinGeckoMarketData,idx:Int) -> AnyView{
       return AnyView(CryptoMarketCard(data: data,size: self.size, rank: idx + 1)
            .buttonify {
               let asset_api = CGCoinAPI.shared
               asset_api.currency = data.id ?? "bitcoin"
               asset_api.getCoinData(completion: { data in
                   guard let safeData = CGCoinAPI.parseCoinData(data: data)  else {return}
                   self.context.selectedCurrency = safeData
               })
            })
    }
    
    var body: some View {
        Container(heading: self.heading, width: totalWidth,ignoreSides: true) { w in
            ZStack{
                if let views = self.view{
                    CardSlidingView(cardSize: size,views: views)
                }else{
                    ProgressView()
                }
            }.onAppear(perform: self.onAppear)
        }
    }
}




struct CryptoMarket_Previews: PreviewProvider {
    static var previews: some View {
        CryptoMarket(heading: "Test")
    }
}
