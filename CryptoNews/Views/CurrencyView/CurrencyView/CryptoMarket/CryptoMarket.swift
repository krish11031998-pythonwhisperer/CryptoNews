//
//  CryptoMarket.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarket: View {
    @StateObject var MAPI:MarketAPI
    var heading:String
    var size:CGSize
    @EnvironmentObject var context:ContextData
    var leadingPadding:Bool
    
    
    init(heading:String,srt:String = "",order:Order = .desc,cardSize:CGSize = CardSize.slender,leadingPadding:Bool = false){
        self.size = cardSize
        self.heading = heading
        self._MAPI = .init(wrappedValue: .init(sort: srt, limit: 10,order: order))
        self.leadingPadding = leadingPadding
    }
    
    func onAppear(){
        if self.MAPI.data.isEmpty{
            self.MAPI.getMarketData()
        }
    }
    
    var view:[AnyView]?{
        if !self.MAPI.data.isEmpty{
            return self.MAPI.data.enumerated().compactMap({self.ViewElement(data: $0.element,idx:$0.offset)})
        }
        
        return nil
    }
    
   func ViewElement(data:CoinMarketData,idx:Int) -> AnyView{
       return AnyView(CryptoMarketCard(data: data,size: self.size, rank: idx + 1)
                      )
//            .buttonify {
//                let asset_api = AssetAPI.shared(currency: data.s ?? "BTC")
//                asset_api.getAssetInfo { data in
//                    guard let safeData = data else {return}
//                    self.context.selectedCurrency = safeData
//                }
//            })
    }
    
    var body: some View {
        Container(heading: self.heading, width: totalWidth,ignoreSides: true) { w in
            ZStack{
                if let views = self.view{
                    CardSlidingView(cardSize: size,views: views,leading: leadingPadding)
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
