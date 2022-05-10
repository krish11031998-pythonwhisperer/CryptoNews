//
//  PortfolioBreakdown.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/03/2022.
//

import SwiftUI

struct PortfolioBreakdown: View {
    @EnvironmentObject var context:ContextData
    var assets:[CrybseAsset]
    var width:CGFloat
    var size:CGSize
    @State var idx:Int = 0
    
    init(asset:[CrybseAsset],width:CGFloat,cardsize:CGSize){
        self.assets = asset.sorted(by: {$0.Rank < $1.Rank})
        self.width = width
        self.size = cardsize
    }
    
    
    var height:CGFloat{
        self.size.height
    }
    
    var totalInvestment:Float{
        return self.assets.reduce(0, {$0 + $1.Value})
    }
    
    var assetColorValuePairs:[Color:Float]{
        var colorValuePairs:[Color:Float] = [:]
        for asset in self.assets{
            colorValuePairs[Color(hex: asset.Color)] = asset.Value
        }
        return colorValuePairs
    }
    
    func assetQuickInfo(asset:CrybseAsset) -> [String:(String,Color)]{
        return [
            "Profit" : (abs(asset.Profit).ToPrettyMoney(),asset.Profit > 0 ? .green : asset.Profit < 0 ? .red : .white),
            "Value":(asset.Value.ToPrettyMoney(),.white),
            "Quantity": (asset.CoinTotal.ToDecimals(),.white),
            "Rank" : ("\(asset.Rank)",.white)
        ]
    }
    
    var arrangedAssets:[CrybseAsset]{
        return self.assets.sorted(by: {$0.Rank < $1.Rank})
    }
    
    func onClose(){
        if self.context.selectedAsset != nil{
            self.context.selectedAsset = nil
        }
    }
    
    var selectedCoinNavLink:some View{
        CustomNavLinkWithoutLabel(isActive:self.$context.showAsset) {
            if let safeAsset = self.context.selectedAsset{
                CurrencyView(asset:safeAsset)
            }
        }

    }
     
    var chartView:some View{
        let selectedAsset:CrybseAsset? = self.idx >= 0 && self.idx < self.arrangedAssets.count ? self.arrangedAssets[idx] : nil
        let selectedColor = selectedAsset == nil ? Color.clear : Color(hex: selectedAsset!.Color)
        return ZStack(alignment: .center) {
            DonutChart(selectedColor: selectedColor,diameter: totalHeight * 0.3,valueColorPair: self.assetColorValuePairs)
            if let currency = selectedAsset?.Currency{
                CurrencySymbolView(currency: currency,width: totalHeight * 0.2)
                    .clipContent(clipping: .circleClipping)
            }
        }
    }
    
    var body: some View {
        Container(heading:"Holdings Breakdown",headingDivider:false, headingSize: 20,width: self.width,ignoreSides: true, orientation: .vertical, alignment: .center){ w in
            self.chartView
                .padding(.vertical)
            ZoomInScrollView(data: self.arrangedAssets, axis: .horizontal,alignment: .center, centralizeStart: true,lazyLoad: false, size: self.size, selectedCardSize: .init(width: self.size.width * 1.25, height: self.size.height * 1.25)) { data, size, selected  in
                if let safeAsset = data as? CrybseAsset{
                    PortfolioCard(asset: safeAsset,w: size.width, chartHeight: size.height * 0.9, selected: selected)
                        .slideZoomInOut(cardSize: size)
                }
            }
            self.selectedCoinNavLink
            
        }.onPreferenceChange(SelectedCentralCardPreferenceKey.self) { idx in
            if self.idx != idx{
                self.idx = idx
            }
        }
    }
}

//struct PortfolioBreakdown_Previews: PreviewProvider {
//    static var previews: some View {
//        PortfolioBreakdown()
//    }
//}
