//
//  AllAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI
import Combine

struct AllAssetView: View {
    @EnvironmentObject var context:ContextData
//    @StateObject var assetAPI:CrybseAssetsAPI = .init(symbols: nil, uid: nil)
    var timer = Timer.TimerPublisher(interval: 150, runLoop: .main, mode: .common).autoconnect()
        
    var assets:CrybseAssets{
        return self.context.userAssets
    }
    
    func coins(type:String) -> [CrybseAsset]?{
        if type == "tracked"{
            return self.assets.trackedAssets
        }else{
            return self.assets.watchingAssets
        }
        
    }
    
    func updateAssetPrices(){
        print("(DEBUG) Currencies : ",self.context.Currencies)
        if self.context.Currencies.count  > 0{
            CrybseMultiCoinPriceAPI.shared.getPrices(coins: self.context.Currencies) { prices in
                for (currency,price) in prices{
                    self.context.userAssets.assets?[currency]?.Price = price.USD
                }
            }
        }
    }
    
    func portfolioCardViews(w:CGFloat) -> [AnyView]{
        return self.coins(type: "tracked")?.sorted(by: {$0.Rank < $1.Rank}).compactMap({AnyView(PortfolioCard(asset:$0, w: w * 0.65))}) ?? []
    }
    
    var portfolioViews:some View{
        Container(heading: "Portfolio", headingColor: .white,ignoreSides: true) { inner_w in
            CardSlidingView(cardSize: .init(width: inner_w * 0.65, height: totalHeight * 0.45), views: self.portfolioCardViews(w: inner_w),leading: true,centralize: true)
        }
    }


    @ViewBuilder var mainBody:some View{
//        self.portfolioViews
//        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins(type: "watching") ?? [], alternative: false)
//        if let uid = self.context.user.user?.uid{
//            PortfolioSummaryView(symbols: self.assets.Tracked,uid: uid)
//        }
        PortfolioSummary(asset: self.assets, width: totalWidth - 30)
        
    }
    
    var body: some View {
        self.mainBody
            .onReceive(self.timer) { _ in
                self.updateAssetPrices()
            }
    }
}

