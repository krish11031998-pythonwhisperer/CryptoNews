//
//  PortfolioMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct PortfolioMain: View {
    @EnvironmentObject var context:ContextData
    var assets:[CrybseAsset]
    var width:CGFloat
    init(assets:[CrybseAsset] = [],width:CGFloat = totalWidth){
        self.assets = assets
        self.width = width
    }
        
    var body: some View {
        StylisticHeaderView(heading: "Portfolio", baseNavBarHeight: totalHeight * 0.4, minimumNavBarHeight: totalHeight * 0.125, headerView: { size in
            PortfolioSummary(width: size.width, height: size.height, showAsContainer: false)
        }, innerView: {
            Container(ignoreSides: true) { w in
                self.portfoliocards(w)
                self.cryptoCurrencyInvestments(.init(width: w, height: totalHeight * 0.15))
                self.InvestmentsSummary(w)
            }
            .frame(width: self.width, alignment: .topLeading)
            .padding(.vertical,20)
        }, bg: Color.AppBGColor.anyViewWrapper(), onClose: self.onClose)
        
        
    }
}

extension PortfolioMain{
    
    var trackedAssets:[CrybseAsset]{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Rank < $1.Rank})
    }
    
    func onClose(){
        if self.context.showPortfolio{
            self.context.showPortfolio.toggle()
        }
    }
    
    var profitableAsset:CrybseAsset?{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Profit > $1.Profit}).first
    }
    
    var leastProfitableAsset:CrybseAsset?{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Profit > $1.Profit}).last
    }
    
    @ViewBuilder func assetInvestmentSummary(heading:String,asset:CrybseAsset,inner_w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: asset.coinData?.Name ?? asset.Currency, fontSize: 22.5, color: .white, fontWeight: .medium)
                .makeAdjacentView(orientation:.horizontal,position: .left) {
                    CurrencySymbolView(currency: asset.Currency,width:40)
                }
            Spacer()
            MoneyTextView(value: asset.Profit,coloredText: true)
        }
        .padding(.top,7.5)
        .frame(width: inner_w, alignment: .center)
        .makeAdjacentView(orientation: .vertical, alignment: .leading, position: .top) {
            MainText(content: heading, fontSize: 13.5, color: .white.opacity(0.5), fontWeight: .semibold)
        }
    }
    
    @ViewBuilder func InvestmentsSummary(_ width:CGFloat) -> some View{
        Container(heading: "Investment Summary", headingColor: .white,headingDivider: true, headingSize: 18, width: width) { inner_w in
            
            MainSubHeading(heading: "Invested Capital", subHeading: self.context.userAssets.InvestedValue.ToPrettyMoney(), headingSize: 13.5, subHeadingSize: 22.5, headColor: .white.opacity(0.5), subHeadColor: .white, headingWeight: .semibold, bodyWeight: .medium)
            
            if let profitableAsset = self.profitableAsset{
                self.assetInvestmentSummary(heading:"Most Profitable Asset",asset: profitableAsset,inner_w: inner_w)
                    .padding(.vertical,5)
            }
            
            if let leastProfitableAsset = self.leastProfitableAsset{
                self.assetInvestmentSummary(heading:"Least Profitable Asset",asset: leastProfitableAsset,inner_w: inner_w)
                    .padding(.vertical,5)
            }
            
//            if let
//
        }
        .animatedAppearance()
    }
    
    var assetColorValuePairs:[Color:Float]{
        var colorValuePairs:[Color:Float] = [:]
        for asset in self.context.userAssets.trackedAssets{
            colorValuePairs[Color(hex: asset.Color)] = asset.Value
        }
        return colorValuePairs
    }
    
    func cryptoCurrencyInvestments(_ size:CGSize) -> some View{
        let h = size.height
        return Container(heading:"Holdings Breakdown",headingSize: 18,width: size.width,ignoreSides: false, orientation: .vertical, alignment: .center){ w in
            DonutChart(diameter: h,valueColorPair: self.assetColorValuePairs)
                .padding(.vertical)
            ForEach(Array(self.trackedAssets.enumerated()),id:\.offset) { _trackedAsset in
                let asset = _trackedAsset.element
                QuickAssetInfoCard(asset: asset,showValue: true,value: (asset.Value * 100/self.assetColorValuePairs.values.reduce(0, {$0 + $1})).ToDecimals() + "%", w: w)
                    .background(Color(hex: asset.Color).clipContent(clipping: .roundClipping))
            }
        }.animatedAppearance()
    }
    
    @ViewBuilder func portfoliocards(_ w:CGFloat) -> some View{
        if !self.trackedAssets.isEmpty{
            Container(heading: "Holdings",headingSize: 18, width: w, ignoreSides: true) { _ in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(Array(self.trackedAssets.enumerated()), id:\.offset) { _asset in
                            let asset = _asset.element
                            let idx = _asset.offset
                            PortfolioCard(asset: asset, w: w * 0.65,h: totalHeight * 0.2)
                                .padding(.leading,idx == 0 ? 15 : 0)
                                .padding(.trailing,idx == self.trackedAssets.count - 1 ? 15 : 0)
                        }
                    }
                }
            }.animatedAppearance()
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
}

struct PortfolioAssetPreview:View{
    @StateObject var crybseAssetsAPI:CrybseAssetsAPI
    init(currencies: [String] = ["LTC","XRP","DOT","AVAX"],uid:String){
        self._crybseAssetsAPI = .init(wrappedValue: .init(symbols:currencies,uid: uid))
    }
    
    func onAppear(){
        if self.crybseAssetsAPI.coinsData == nil{
            self.crybseAssetsAPI.getAssets()
        }
    }
    
    var body: some View{
        
        ZStack(alignment:.center){
            mainBGView.ignoresSafeArea()
            if let assets = self.crybseAssetsAPI.coinsData?.trackedAssets{
                Container(horizontalPadding: 7.5){ w in
                    PortfolioMain(assets: assets, width: w)
                }
            }else{
                ProgressView()
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            .ignoresSafeArea()
        .onAppear(perform: self.onAppear)
    }
    
    
}

struct PortfolioMain_Previews: PreviewProvider {
    
    @StateObject static var contextData:ContextData = ContextData()
    
    static var previews: some View {
        ScrollView {
            PortfolioAssetPreview(uid:"jV217MeUYnSMyznDQMBgoNHfMvH2")
                .environmentObject(PortfolioMain_Previews.contextData)
        }
        
    }
}
