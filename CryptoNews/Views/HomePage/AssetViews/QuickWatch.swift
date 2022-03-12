//
//  QuickWatch.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/03/2022.
//

import SwiftUI

struct QuickWatch: View {
    var assets:Array<CrybseAsset>
    var width:CGFloat
    init(assets:Array<CrybseAsset>,width:CGFloat = totalWidth){
        self.assets = assets
        self.width = width
    }
    
    
    @ViewBuilder func rowAsset(asset:CrybseAsset,w: CGFloat) -> some View{
        if let price = asset.Price{
            let changeColor = asset.Change > 0 ? Color.green : asset.Change < 0 ? Color.red : Color.white
            HStack(alignment: .center, spacing: 20) {
                CurrencySymbolView(currency: asset.Currency,width: 30)
                MainText(content: asset.Currency, fontSize: 16, color: .white, fontWeight: .medium)
                Spacer()
                MainText(content: price.ToMoney(), fontSize: 16, color: .white, fontWeight: .semibold)
                PercentChangeView(value: asset.Change,type: "small")
            }.frame(width: w, alignment: .center)
        }
    }
    
    var body: some View {
        Container(heading: "Quick Watch", headingColor: .white, headingDivider: true, width: self.width,spacing: 15) { w in
            ForEach(Array(self.assets.enumerated()), id:\.offset) { _asset in
                let asset = _asset.element
                self.rowAsset(asset: asset, w: w)
            }
        }.basicCard()
    }
}

//struct QuickWatch_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickWatch()
//    }
//}
