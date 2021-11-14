//
//  TrackedAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/11/2021.
//

import Foundation
import SwiftUI

struct TrackedAssetView:View{
    var asset:[String]
    
    init(asset:[String]){
        self.asset = asset
    }
    
    var cardSize:CGSize{
        return .init(width: totalWidth * 0.5, height: totalHeight * 0.4)
    }
    
    var views:[AnyView]{
        return self.asset.compactMap({AnyView(PriceCard(currency: $0))})
    }
    
    var body:some View{
       
        Container(heading: "Tracked Assets", width: totalWidth, ignoreSides: true) { w in
            CardSlidingView(cardSize: self.cardSize, views: self.views, leading: false)
        }
    }
    
}
