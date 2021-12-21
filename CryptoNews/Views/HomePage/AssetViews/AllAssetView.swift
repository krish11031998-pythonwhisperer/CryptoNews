//
//  AllAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI

struct AllAssetView: View {
    
    @StateObject var coinRankAPI:CoinRankCoinsAPI
    @EnvironmentObject var context:ContextData
    var type:String
    init(type:String,currencies:[String]){
        self.type = type
        self._coinRankAPI = .init(wrappedValue: .init(timePeriod: "3h", symbols: currencies))
    }
    
    func onAppear(){
        if self.coinRankAPI.coins == nil{
            self.coinRankAPI.getCoinsData()
        }
    }
    
    var alternativeView:Bool{
        self.type != "tracked"
    }
    
    var heading:String{
        self.type == "tracked" ? "Tracked Assets" : "Watched Assets"
    }
    
    var coins:[CoinData]{
        self.coinRankAPI.coins?.data?.coins ?? []
    }
    
    var commonCoins:[String]{
        self.type == "tracked" ? self.context.trackedAssets : self.context.watchedAssets
    }
    
    var views:[AnyView]{
        self.coins.filter({self.commonCoins.contains($0.Symbol)}).compactMap({AnyView(PriceCard(coin: $0,alternativeView: self.alternativeView))})
    }

    @ViewBuilder var mainBody:some View{
        AssetViewBuilder(type: "tracked", coins: self.coins.filter({self.context.trackedAssets.contains($0.Symbol)}), alternative: false)
        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins.filter({self.context.watchedAssets.contains($0.Symbol)}), alternative: true)
    }
    
    var body: some View {
        self.mainBody
        .onAppear(perform: self.onAppear)
    }
}



//struct AllAssetView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllAssetView()
//    }
//}
