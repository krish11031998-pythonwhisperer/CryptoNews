//
//  CryptoMarket.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarket: View {
    @StateObject var MAPI:MarketAPI = .init()
    @EnvironmentObject var context:ContextData
    func onAppear(){
        if self.MAPI.data.isEmpty{
            self.MAPI.getMarketData()
        }
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5)
    
    var view:[AnyView]?{
        if !self.MAPI.data.isEmpty{
            return self.MAPI.data.enumerated().compactMap({self.ViewElement(data: $0.element,idx:$0.offset)})
        }
        
        return nil
    }
    
    func ViewElement(data:CoinMarketData,idx:Int) -> AnyView{
        AnyView(
            Button(action: {
                print("Hello")
                let asset_api = AssetAPI.shared(currency: data.s ?? "BTC")
                asset_api.getAssetInfo { data in
                    guard let safeData = data else {return}
                    self.context.selectedCurrency = safeData
                }
            }, label: {
                CryptoMarketCard(data: data,size: cardSize, rank: idx + 1)
            }).springButton()
        )

    }
    
    var body: some View {
        Container(heading: "Crypto Market", width: totalWidth) { w in
            ZStack{
                if let views = self.view{
                    CardSlidingView(cardSize: .init(width: cardSize.width, height: cardSize.height),views: views)
                }else{
                    ProgressView()
                }
            }.onAppear(perform: self.onAppear)
        }
    }
}




struct CryptoMarket_Previews: PreviewProvider {
    static var previews: some View {
        CryptoMarket()
    }
}
