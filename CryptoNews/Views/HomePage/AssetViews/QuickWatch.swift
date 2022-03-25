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
            ForEach(Array(self.assets.sorted(by: {$0.Rank < $1.Rank}).enumerated()), id:\.offset) { _asset in
                let asset = _asset.element
                QuickAssetInfoCard(asset: asset, w: w)
                    .animatedAppearance(idx: _asset.offset)
            }
        }
//        .basicCard()
    }
}


struct QuickAssetInfoCard:View{
    @EnvironmentObject var context:ContextData
    var showValue:Bool
    var value:String? = nil
    var asset:CrybseAsset
    var w: CGFloat
    
    init(asset:CrybseAsset,showValue:Bool = false,value:String? = nil,w:CGFloat){
        self.asset = asset
        self.w = w
        self.value = value
        self.showValue = showValue
    }
    
    var NumericalValue:String?{
        return self.value ?? (self.showValue ? self.asset.value : self.asset.Price)?.ToMoney()
    }
    
    func quickInfoAssetCard(value:String) -> some View{

        Container(width:w,horizontalPadding: 10,verticalPadding: 10,orientation: .horizontal){ _ in
            CurrencySymbolView(currency: asset.Currency,width: 30)
            MainText(content: asset.Currency, fontSize: 16, color: .white, fontWeight: .medium)
            Spacer()
            MainText(content: value, fontSize: 16, color: .white, fontWeight: .semibold)
            if !self.showValue{
                PercentChangeView(value: asset.Change,type: "small")
            }
        }
        .buttonify(type: .shadow){
            if self.context.selectedAsset != asset{
                self.context.selectedAsset = asset
            }
        }
        .frame(width: w, alignment: .center)
        .borderCard(color: Color.white.opacity(0.5) , clipping: .roundClipping)
        
    }
    
    var assetInfoView:some View{
        Container(width:w,horizontalPadding: 10, verticalPadding: 10, orientation: .horizontal){ inner_w in
            if let sparkline = self.asset.coinData?.sparkline{
                let firstPrice = sparkline.first ?? 0
                let lastestPrice = sparkline.last ?? 0
                let chartColor:Color = lastestPrice > firstPrice ? .green :  lastestPrice < firstPrice ? .red : .white
                CurveChart(data: sparkline,interactions: false, size: .init(width: inner_w, height: 75), bg: .clear, lineColor: chartColor)
            }
        }
//        .background(Color(hex: self.asset.Color))
//        .clipContent(clipping: .roundClipping)
    }
    
    var body: some View{
        if let value = self.NumericalValue{
            self.quickInfoAssetCard(value: value)
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
