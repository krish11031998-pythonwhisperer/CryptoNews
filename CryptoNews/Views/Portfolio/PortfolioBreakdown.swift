//
//  PortfolioBreakdown.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/03/2022.
//

import SwiftUI

struct PortfolioBreakdown: View {
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


    @ViewBuilder func assetCard(data:Any,size:CGSize) -> some View{
        if let safeAsset = data as? CrybseAsset{
            let percent = (safeAsset.Value * 100/self.totalInvestment).ToDecimals() + "%"
            let assetKeyValue = self.assetQuickInfo(asset: safeAsset)
            Container(width: size.width){ w in
                MainText(content: safeAsset.Currency, fontSize: 20, color: .white, fontWeight: .medium)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left){
                        CurrencySymbolView(currency: safeAsset.Currency,width: 20)
                    }
                MainText(content: percent, fontSize: 30, color: .gray, fontWeight: .medium)
                    .frame(width: w, alignment: .trailing)
                if self.assets[self.idx].Currency == safeAsset.Currency{
//                    MainText(content: "Selected", fontSize: 15, color: .white, fontWeight: .medium)
                    LazyVGrid(columns: [.init(.adaptive(minimum: w * 0.5 - 5, maximum: w * 0.5 - 5), spacing: 10)], alignment: .center, spacing: 10) {
                        ForEach(assetKeyValue.keys.sorted(), id:\.self){key in
                            if let value = assetKeyValue[key]{
                                MainSubHeading(heading: key, subHeading: value.0, headingSize: 12.5, subHeadingSize: 15, headColor: .white, subHeadColor: value.1, headingWeight: .medium, bodyWeight: .medium, spacing: 3.5,alignment: .center)
                            }
                        }
                    }
                }
            }
            .basicCard(size: size)
            .borderCard(color: .init(hex: safeAsset.Color))
            
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
     
    var body: some View {
        Container(heading:"Holdings Breakdown",headingSize: 18,width: self.width,ignoreSides: true, orientation: .vertical, alignment: .center){ w in
            DonutChart(selectedColor: self.idx >= 0 && self.idx < self.assets.count ? Color(hex:self.assets.sorted(by: {$0.Rank < $1.Rank})[self.idx].Color) : nil,diameter: totalHeight * 0.3,valueColorPair: self.assetColorValuePairs)
                .padding(.vertical)
            ZoomInScrollView(data: self.assets, axis: .horizontal, centralizeStart: true, size: self.size, selectedCardSize: .init(width: self.size.width, height: self.size.height * 1.5)) { data, size, selected  in
                if let safeAsset = data as? CrybseAsset{
                    PortfolioCard(asset: safeAsset,w: size.width, h: size.height, selected: selected)
                        .slideZoomInOut(cardSize: size)
                }
            }
            .animatedAppearance()
                
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
