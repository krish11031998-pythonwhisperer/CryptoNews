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
    
    var views:[AnyView]{
        return self.asset.compactMap({AnyView(PriceCard(currency: $0))})
    }
    
    var body:some View{
       
        Container(heading: "Tracked Assets", width: totalWidth, ignoreSides: true) { w in
            CardSlidingView(cardSize: CardSize.normal, views: self.views, leading: false)
        }
    }
    
}
