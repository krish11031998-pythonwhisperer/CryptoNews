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
    @StateObject var aotAPI:CrybseAssetOverTimeManager = .init()
    var width:CGFloat
    var height:CGFloat
    var showAsContainer:Bool
    var assetCancellable:AnyCancellable? = nil
    @State var choosenPrice:Int = -1
    
    init(width:CGFloat = totalWidth - 20,height:CGFloat = totalHeight * 0.2,showAsContainer:Bool = true){
        self.width = width
        self.height = height
        self.showAsContainer = showAsContainer
    }
    
    var assets:CrybseAssets{
        return self.context.userAssets
    }
    
    
    var assetOverTime:CrybseAssetOverTime?{
        return self.aotAPI.assetOverTime
    }
    
    func onAppear(){
        guard let uid = self.context.user.user?.uid else {return}
        if self.aotAPI.assetOverTime == nil{
            self.aotAPI.getPortfolioOverTime(uid: uid)
        }
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            if let currentValue = self.assetOverTime?.currentPortfolioValue{
                MainSubHeading(heading: "Current Portfolio Value", subHeading:currentValue.ToMoney(), headingSize: 15, subHeadingSize: 25, headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium, spacing: 10, alignment: .leading)
            }
            Spacer()
            if let change = self.assetOverTime?.change{
                PercentChangeView(value: (change * 100), type: "large")
            }
            
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
            if self.context.selectedAsset != asset{
                self.context.selectedAsset = asset
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
    
    @ViewBuilder func portfolioValueOverTimeSummaryDetails(w:CGFloat) -> some View{
        let chartSize:CGSize = .init(width: w, height: totalHeight * 0.175)
        if let portfolioValueTimeline = self.assetOverTime?.portfolioTimeline{            
            CurveChart(data: portfolioValueTimeline, choosen: self.$choosenPrice, interactions: true, size: chartSize,bg: .clear, lineColor: nil, chartShade: true)
            if self.showAsContainer{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(Array(self.TrackedAssets.enumerated()),id:\.offset){ _asset in
                            let asset = _asset.element
                            HStack(alignment: .center, spacing: 10) {
                                CurrencySymbolView(currency: asset.Currency, width: 15  )
                                MainSubHeading(heading: asset.Currency, subHeading: asset.Profit.ToMoney(), headingSize: 15, subHeadingSize: 15,headColor: .white, subHeadColor: asset.Profit == 0 ? .white : asset.Profit > 0 ? .green : .red, orientation: .horizontal, headingWeight: .medium, bodyWeight: .semibold, spacing: 15, alignment: .center)
                            }
                            .padding(7.5)
                            .basicCard()
                            .borderCard(color: Color.white, clipping: .roundClipping)
                        }
                    }
                    .padding(.horizontal,5)
                    .padding(.vertical)
                }
                MainText(content: "View Portfolio", fontSize: 10, color: .white, fontWeight: .medium)
                    .padding(7.5)
                    .basicCard()
                    .borderCard(color: .white, clipping: .roundClipping)
                    .buttonify {
                        if !self.context.showPortfolio{
                            self.context.showPortfolio.toggle()
                        }
                    }

            }
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
    }
    
    @ViewBuilder func mainBody(w:CGFloat) -> some View{
        if let _ = self.assetOverTime{
            self.header
            self.portfolioValueOverTimeSummaryDetails(w: w)
        }else{
            ProgressView()
                .frame(width: w, height: totalHeight * 0.2, alignment: .center)
        }
    }
    
    var body: some View {
        Container(heading: self.showAsContainer ? "Portfolio" : nil, headingColor: .white, headingDivider: true, width: self.width, verticalPadding:15) { w in
            self.mainBody(w: w)
        }
        .basicCard(background: self.showAsContainer ? BlurView.thinDarkBlur.anyViewWrapper() : Color.clear.anyViewWrapper())
        .onAppear(perform: self.onAppear)

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
        }
        .onAppear(perform: self.assetAPI.getAssets)
    }
    
}

struct PortfolioSummary_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioSummaryView(symbols: ["DOT","XRP",""], uid: "jV217MeUYnSMyznDQMBgoNHfMvH2")
    }
}
