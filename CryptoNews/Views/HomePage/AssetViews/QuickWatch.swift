//
//  QuickWatch.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/03/2022.
//

import SwiftUI

struct QuickWatch: View {
    @EnvironmentObject var context:ContextData
    var assets:Array<CrybseAsset>
    var width:CGFloat
    init(assets:Array<CrybseAsset>,width:CGFloat = totalWidth){
        self.assets = assets
        self.width = width
    }

    var body: some View {
        Container(heading: "Quick Watch", headingColor: .white, headingDivider: true, width: self.width,spacing: 20) { w in
            ForEach(Array(self.assets.enumerated()), id:\.offset) { _asset in
                let asset = _asset.element
                QuickAssetInfoCard(asset: asset, w: w)
            }
        }
        .basicCard()
    }
}


struct QuickAssetInfoCard:View{
    @EnvironmentObject var context:ContextData
    var showValue:Bool
    var asset:CrybseAsset
    var w: CGFloat
    
    init(asset:CrybseAsset,showValue:Bool = false,w:CGFloat){
        self.asset = asset
        self.w = w
        self.showValue = showValue
    }
    
    var NumericalValue:Float?{
        return self.showValue ? self.asset.value : self.asset.Price
    }
    
    var body: some View{
        if let value = self.NumericalValue{
            HStack(alignment: .center, spacing: 20) {
                CurrencySymbolView(currency: asset.Currency,width: 30)
                MainText(content: asset.Currency, fontSize: 16, color: .white, fontWeight: .medium)
                Spacer()
                MainText(content: value.ToMoney(), fontSize: 16, color: .white, fontWeight: .semibold)
                if !self.showValue{
                    PercentChangeView(value: asset.Change,type: "small")
                }
            }
            .padding(.vertical,10)
            .padding(.horizontal,5)
            .buttonify(type: .shadow){
                if self.context.selectedAsset != asset{
                    self.context.selectedAsset = asset
                }
            }
            .frame(width: w, alignment: .topLeading)
            .borderCard(color: Color.white.opacity(0.5) , clipping: .roundClipping)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
}

//struct QuickWatch_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickWatch()
//    }
//}
