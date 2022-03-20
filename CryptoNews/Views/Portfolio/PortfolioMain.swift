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
    
    var trackedAssets:[CrybseAsset]{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Rank < $1.Rank})
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
        }
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
            self.cryptoCurrencyInvestments(.init(width: w, height: totalHeight * 0.15))
                .animatedAppearance()
            //            }.basicCard()
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    func onClose(){
        if self.context.showPortfolio{
            self.context.showPortfolio.toggle()
        }
    }
    
    var body: some View {
        StylisticHeaderView(heading: "Portfolio", baseNavBarHeight: totalHeight * 0.4, minimumNavBarHeight: totalHeight * 0.125, headerView: { size in
            PortfolioSummary(width: size.width, height: size.height, showAsContainer: false)
        }, innerView: {
            Container(ignoreSides: true) { w in
                self.portfoliocards(w)
            }
            .frame(width: self.width, alignment: .topLeading)
            .padding(.top,20)
        }, bg: Color.AppBGColor.anyViewWrapper(), onClose: self.onClose)
        
        
    }
}


struct PortfolioAssetPreview:View{
    @StateObject var crybseAssetsAPI:CrybseAssetsAPI
    init(currencies: [String] = ["LTC","XRP","DOT"],uid:String){
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
        }.ignoresSafeArea()
        
    }
}
