//
//  PortfolioAsset.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct PortfolioAsset: View {
    @EnvironmentObject var context:ContextData
    var asset:CrybseAsset
    var width:CGFloat
    init(asset:CrybseAsset,width:CGFloat){
        self.asset = asset
        self.width = width
    }
    
    
    var heading:some View{
        HStack(alignment: .center, spacing: 10) {
            CurrencySymbolView(currency: self.asset.Currency, width: 25)
            MainText(content: self.name, fontSize: 17.5,color: .black,fontWeight: .medium)
        }.padding(.bottom,10)
    }
    
    func curveChartView(inner_w:CGFloat) -> some View{
        CurveChart(data: self.asset.CoinData.Sparkline, interactions: false, size: .init(width: inner_w, height: 95),bg: .clear,chartShade: false)
    }
    
    func infoView(inner_w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            self.heading
            MainSubHeading(heading: self.change.0, subHeading: self.assetHolding, headingSize: 13, subHeadingSize: 17, headColor: self.change.1, subHeadColor: .black, alignment: .leading)
        }.frame(width: inner_w, alignment: .leading)
    }
    
    var body: some View {
        Container(width:self.width,ignoreSides:false,horizontalPadding: 7.5,verticalPadding: 5) { inner_w in
            HStack(alignment: .center, spacing: 10) {
                self.infoView(inner_w: inner_w * 0.45 - 10)
                
//                Spacer()
                self.curveChartView(inner_w: inner_w * 0.55)
            }.frame(width: inner_w, alignment: .topLeading)
            
            
        }.buttonify(type:.shadow,withBG: true,clipping: .roundClipping){
                setWithAnimation {
                    if self.context.selectedAsset?.Currency != self.asset.Currency{
                        self.context.selectedAsset = self.asset
                    }
                }
            }
        
    }
}

extension PortfolioAsset{
    
    var name:String{
        self.asset.CoinData.Name ?? ""
    }
    
    var change:(String,Color){
        let val = self.asset.CoinData.change ?? 0
        let color = val < 0 ? Color.red : Color.green
        return ("\(val)",color)
    }
    
    
    
    
    var assetHolding:String{
        let val = self.asset.Value
        return val.ToMoney()
    }
    
}
//
//struct PortfolioAsset_Previews: PreviewProvider {
//    static var previews: some View {
//        PortfolioAsset()
//    }
//}
