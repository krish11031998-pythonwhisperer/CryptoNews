//
//  PortfolioSummary.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/02/2022.
//

import SwiftUI
import Combine

struct PortfolioSummary: View {
    @EnvironmentObject var context:ContextData
//    @ObservedObject var assets:CrybseAssets
    var width:CGFloat
    var height:CGFloat
    var assetCancellable:AnyCancellable? = nil
    
    init(width:CGFloat = totalWidth - 20,height:CGFloat = totalHeight * 0.2){
        self.width = width
        self.height = height
    }
    
    var assets:CrybseAssets{
        return self.context.userAssets
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: "Total Value", subHeading: self.assets.TotalCurrentValue.ToMoney(), headingSize: 15, subHeadingSize: 25, headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium, spacing: 10, alignment: .leading)
            Spacer()
            PercentChangeView(value: self.assets.Profit, type: "large")
        }
    }
        
    func portfolioSummaryAssetCard(asset:CrybseAsset,width:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .center, spacing: 10) {
                    CurrencySymbolView(currency: asset.Currency, width:25)
                    MainText(content: asset.Currency, fontSize: 12.5, color: .black, fontWeight: .medium)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    MainText(content: asset.Price?.ToMoney() ?? "0.0", fontSize: 12.5, color: .black, fontWeight: .medium)
                    PercentChangeView(value: asset.Change,type: "small")
                }
            }.frame(width: width, alignment: .topLeading)
    
            
            if let sparkline = asset.coinData?.Sparkline{
                CurveChart(data: sparkline, interactions: false, size: .init(width: width, height: 100),bg: .clear,chartShade: true)
            }
        }
        .padding(12.5)
        .basicCard(background: AnyView(mainLightBGView))
        .buttonify {
            if self.context.selectedCurrency != asset{
                self.context.selectedCurrency = asset
            }
        }
    }
    
    var TrackedAssets:[CrybseAsset]{
        return self.assets.Tracked.compactMap({self.context.userAssets.assets?[$0]}).sorted(by: {$0.Rank < $1.Rank})
    }
    
    var assetsView:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(Array(self.TrackedAssets.enumerated()), id:\.offset) { _asset in
                    let asset = _asset.element
                    PortfolioCard(asset: asset, w: self.width * 0.65,h: self.height)
                }
            }
        }
    }
    
    var body: some View {
        Container(heading: "Portfolio", headingColor: .white, headingDivider: true, width: self.width, verticalPadding:15) { w in
            self.header
            self.assetsView
        }.basicCard()
            .onReceive(self.context.userAssets.objectWillChange) { _ in
                print("(DEBUG) Change in the userAsset Data")
            }
    }
}

struct PortfolioSummaryAssetCard:View{
    @ObservedObject var asset:CrybseAsset
    var width:CGFloat
    init(asset:CrybseAsset,width:CGFloat){
        self.asset = asset
        self.width = width
    }
    
    var body: some View{
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
            }.frame(width: width, alignment: .topLeading)
    
            
            if let sparkline = asset.coinData?.Sparkline{
                CurveChart(data: sparkline, interactions: false, size: .init(width: width, height: 100),bg: .clear,chartShade: true)
            }
        }.padding()
        .background(BlurView.thinDarkBlur)
        .clipContent(clipping: .roundClipping)
        .onReceive(self.asset.objectWillChange) { _ in
            print("(DEBUG) \(self.asset.Currency) New Price : ",self.asset.Price)
        }
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
                PortfolioSummary()
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
