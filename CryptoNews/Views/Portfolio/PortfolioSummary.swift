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
    @State var assetOverTime:CrybseAssetOverTime? = nil
    @State var choosenPrice:Int = -1
    var width:CGFloat
    var height:CGFloat
    var showAsContainer:Bool
    var assetCancellable:AnyCancellable? = nil
    
    
    init(assetOverTime:CrybseAssetOverTime? = nil,width:CGFloat = totalWidth - 20,height:CGFloat = totalHeight * 0.2,showAsContainer:Bool = true){
        self.width = width
        self.height = height
        self.showAsContainer = showAsContainer
        self._assetOverTime = .init(wrappedValue: assetOverTime)
    }
    
    var assets:CrybseAssets{
        return self.context.userAssets
    }
        
    func onAppear(){
        guard let uid = self.context.user.user?.uid else {return}
        if self.assetOverTime == nil{
            CrybseAssetOverTimeManager.shared.getPortfolioOverTime(uid: uid) { data in
                if let safeAssetOverTime = CrybseAssetOverTime.parseCrybseAssetOverTime(data: data){
                    setWithAnimation {
                        self.assetOverTime = safeAssetOverTime
                        if self.context.assetOverTime == nil{
                            self.context.assetOverTime = safeAssetOverTime
                        }
                    }
                }
            }
        }
    }
    
    var currentValue:Float{
        if let portfolioValue = self.assetOverTime?.PortfolioTimeline, self.choosenPrice >= 0 && self.choosenPrice < portfolioValue.count{
            return portfolioValue[self.choosenPrice]
        }else{
            return self.assetOverTime?.CurrentPortfolioValue ?? 0.0
        }
    }
    
    var header:some View{
        Container(width:self.width,verticalPadding: 0,orientation: .horizontal, aligment: .center, spacing: 10) { w in
            MainSubHeading(heading: "Current Portfolio Value", subHeading:currentValue.ToMoney(), headingSize: 20, subHeadingSize: 25, headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium, spacing: 10, alignment: .leading)
            Spacer()
            if let change = self.assetOverTime?.change{
                PercentChangeView(value: (change * 100), type: "large")
            }
        }
        .frame(width: self.width, height: self.height * 0.25, alignment: .center)
    }

    var TrackedAssets:[CrybseAsset]{
        return self.assets.Tracked.compactMap({self.context.userAssets.assets?[$0]}).sorted(by: {$0.Rank < $1.Rank})
    }
    
    @ViewBuilder var portfolioHoldingProfitSummary:some View{
        if self.assetOverTime != nil{
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    ForEach(Array(self.TrackedAssets.enumerated()),id:\.offset){ _asset in
                        let asset = _asset.element
                        HStack(alignment: .center, spacing: 10) {
                            CurrencySymbolView(currency: asset.Currency, width: 15 )
                            MainSubHeading(heading: asset.Currency, subHeading: asset.Profit.ToMoney(), headingSize: 15, subHeadingSize: 15,headColor: .white, subHeadColor: asset.Profit == 0 ? .white : asset.Profit > 0 ? .green : .red, orientation: .horizontal, headingWeight: .medium, bodyWeight: .semibold, spacing: 15, alignment: .center)
                        }
                        .padding(7.5)
                        .background(BlurView.thinDarkBlur.clipContent(clipping: .roundClipping))
                        .borderCard(color: Color.white, clipping: .roundClipping)
                    }
                }.padding(.horizontal)
                    .padding(.vertical,5)
            }
        }else if CrybseAssetOverTimeManager.shared.loading{
            ProgressView()
        }

    }
    
    @ViewBuilder func portfolioValueOverTimeSummaryDetails(w:CGFloat) -> some View{
        let chartSize:CGSize = .init(width: w, height: self.height * (self.showAsContainer ? 0.5 : 0.75))
        if let portfolioValueTimeline = self.assetOverTime?.portfolioTimeline{            
            CurveChart(data: portfolioValueTimeline, choosen: self.$choosenPrice, interactions: true, size: chartSize,bg: .clear, lineColor: nil, chartShade: true)
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
    }
    
    @ViewBuilder func mainBody(w:CGFloat) -> some View{
        if let _ = self.assetOverTime{
            self.header
            Container(width: w,verticalPadding: 0) { inner_w in
                self.portfolioValueOverTimeSummaryDetails(w: inner_w)
            }
            if self.showAsContainer{
                Container(width:w,ignoreSides: true,verticalPadding: 0,spacing: 5){ _ in
                    self.portfolioHoldingProfitSummary
                }
                .frame(width: w, height: self.height * 0.25, alignment: .center)
            }
        }else if CrybseAssetOverTimeManager.shared.loading{
            ProgressView()
                .frame(width: w, height: totalHeight * 0.2, alignment: .center)
        }else if !CrybseAssetOverTimeManager.shared.loading{
            MainText(content: "No Portfolio Holding", fontSize: 30, color: .white, fontWeight: .medium,padding: 15)
        }
    }
    
    func rightButton() -> AnyView{
        if self.showAsContainer{
            return MainText(content: "View Portfolio", fontSize: 10, color: .white, fontWeight: .medium)
                .padding(7.5)
                .basicCard()
                .borderCard(color: .white, clipping: .roundClipping)
                .buttonify {
                    if self.context.assetOverTime != self.assetOverTime{
                        self.context.assetOverTime = self.assetOverTime
                    }
                    if self.context.tab != .portfolio{
                        self.context.tab = .portfolio
                    }
                }
                .anyViewWrapper()
        }else{
            return Color.clear.anyViewWrapper()
        }
    }
    
    var body: some View {
        Container(heading: self.showAsContainer ? "Portfolio" : nil, headingColor: .white, headingDivider: true, width: self.width,ignoreSides: true, verticalPadding:15,spacing: 10,rightView: self.rightButton) { w in
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
    
            
            if let sparkline = asset.CoinData.Sparkline{
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
