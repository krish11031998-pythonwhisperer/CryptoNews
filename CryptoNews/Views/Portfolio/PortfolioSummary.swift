//
//  PortfolioSummary.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/02/2022.
//

import SwiftUI
struct PortfolioSummary: View {
    @EnvironmentObject var context:ContextData
    var assets:CrybseAssets
    var width:CGFloat
    
    init(asset:CrybseAssets,width:CGFloat = totalWidth - 20){
        self.assets = asset
        self.width = width
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: "Total Value", subHeading: self.assets.TotalCurrentValue.ToMoney(), headingSize: 15, subHeadingSize: 25, headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium, spacing: 10, alignment: .leading)
            Spacer()
            PercentChangeView(value: self.assets.Profit, type: "large")
        }
    }
    
    func assetCardView(asset:CrybseAsset,w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .center, spacing: 10) {
                    CurrencySymbolView(currency: asset.Currency, width:25)
                    MainText(content: asset.Currency, fontSize: 12.5, color: .white, fontWeight: .medium)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    MainText(content: asset.Price?.ToMoney() ?? "0.0", fontSize: 12.5, color: .white, fontWeight: .medium)
                    PercentChangeView(value: asset.Change,type: "small")
                }
            }.frame(width: w, alignment: .topLeading)
    
            
            if let sparkline = asset.coinData?.Sparkline{
                CurveChart(data: sparkline, interactions: false, size: .init(width: w, height: 100),bg: .clear,chartShade: true)
            }
        }.padding()
        .background(BlurView.thinDarkBlur)
        .clipContent(clipping: .roundClipping)
    }
    
    var assetsView:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(self.assets.Tracked, id:\.self) { assetName in
                    if let asset = self.assets.assets?[assetName]{
                        self.assetCardView(asset: asset, w: self.width * 0.35)
                            .buttonify {
                                if self.context.selectedCurrency != asset{
                                    self.context.selectedCurrency = asset
                                }
                            }
                    }
                }
            }
        }
    }
    
    var body: some View {
        Container(heading: "Portfolio", headingColor: .white, headingDivider: true, width: self.width, verticalPadding:15) { w in
            self.header
            self.assetsView
        }.basicCard()
    }
}

struct PortfolioSummaryView:View{
    @StateObject var assetAPI:CrybseAssetsAPI
    
    init(symbols:[String],uid:String){
        self._assetAPI = .init(wrappedValue: .init(symbols: symbols, uid: uid))
    }
    
    var body:some View{
        ZStack(alignment: .center) {
            if let safeAssets = self.assetAPI.coinsData{
                PortfolioSummary(asset: safeAssets)
            }else{
                ProgressView()
            }
        }.onAppear(perform: self.assetAPI.getAssets)
    }
    
}

struct PortfolioSummary_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioSummaryView(symbols: ["DOT","XRP",""], uid: "jV217MeUYnSMyznDQMBgoNHfMvH2")
    }
}
