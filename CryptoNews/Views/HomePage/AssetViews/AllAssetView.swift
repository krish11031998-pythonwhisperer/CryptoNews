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
    var userAssetCancelable:AnyCancellable? = nil
    
    func coins(type:String) -> [CrybseAsset]?{
        if type == "tracked"{
            return self.context.userAssets.trackedAssets
        }else{
            return self.context.userAssets.watchingAssets
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
        self.portfolioViews
        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins(type: "watching") ?? [], alternative: false)
    }
    
    var body: some View {
        self.mainBody
    }
}

