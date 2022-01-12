//
//  AllAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI

struct AllAssetView: View {
    
//    @StateObject var coinRankAPI:CoinRankCoinsAPI
    @StateObject var crybseAssetsAPI:CrybseAssetsAPI
    @EnvironmentObject var context:ContextData

    
    init(uid:String,currencies:[String]){
        self._crybseAssetsAPI = .init(wrappedValue: .init(symbols: currencies, uid: uid))
    }
    
    func onAppear(){
        
        if self.crybseAssetsAPI.coinsData == nil{
            self.crybseAssetsAPI.getAssets()
        }
        
    }

    func coins(type:String) -> [CrybseAsset]{
        if type == "tracked"{
            return self.crybseAssetsAPI.coinsData?.tracked ?? []
        }else{
            return self.crybseAssetsAPI.coinsData?.watching ?? []
        }
        
    }


    @ViewBuilder var mainBody:some View{
//        AssetViewBuilder(type: "tracked", coins: self.coins(type: "tracked"), alternative: false)
        PortfolioMain(assets: self.coins(type: "tracked")).environmentObject(self.context)
        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins(type: "watching"), alternative: false)
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
