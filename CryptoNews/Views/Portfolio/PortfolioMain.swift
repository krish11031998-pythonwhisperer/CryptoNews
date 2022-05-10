//
//  PortfolioMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct PortfolioMain: View {
    @EnvironmentObject var context:ContextData
    var assetOverTime:CrybseAssetOverTime?
    var assets:[CrybseAsset]
    var width:CGFloat
    init(assetOverTime:CrybseAssetOverTime? = nil,assets:[CrybseAsset] = [],width:CGFloat = totalWidth){
        self.assetOverTime = assetOverTime
        self.assets = assets
        self.width = width
    }
        
    var body: some View {
        CustomNavigationView{
            StylisticHeaderView(heading: "Portfolio", baseNavBarHeight: totalHeight * 0.4, minimumNavBarHeight: totalHeight * 0.125, headerView: { size in
                PortfolioSummary(assetOverTime:self.assetOverTime,width: size.width, height: size.height, showAsContainer: false)
            }, innerView: {
                Container(ignoreSides: true) { w in
                    self.infoBlock(heading: "Investment ", width: w, innerView: self.InvestmentsSummary(_:))
                    self.infoBlock(heading: "Top Movers", width: w, innerView: self.TopThreeMovers(_:))
                    PortfolioBreakdown(asset: self.assets,width: w, cardsize: .init(width: w * 0.5, height: totalHeight * 0.35))
                        .animatedAppearance()
                    
                }
                .frame(width: self.width, alignment: .topLeading)
                .padding(.vertical,50)
                
            }, bg: Color.AppBGColor.anyViewWrapper())
        }
        
    }
}


extension PortfolioMain{

    var trackedAssets:[CrybseAsset]{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Rank < $1.Rank})
    }
    
    var profitableAsset:CrybseAsset?{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Profit > $1.Profit}).first
    }
    
    var leastProfitableAsset:CrybseAsset?{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Profit > $1.Profit}).last
    }
    
    @ViewBuilder func assetInvestmentSummary(heading:String,asset:CrybseAsset,inner_w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: asset.CoinData.Name, fontSize: 22.5, color: .white, fontWeight: .medium)
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
    
    @ViewBuilder func infoBlock<T:View>(heading:String,width:CGFloat,@ViewBuilder innerView: @escaping (CGFloat) -> T) -> some View{
        Container(heading: heading, headingDivider: false, headingSize: 22.5, width: width,ignoreSides: false,aligment: .center) { inner_w in
            innerView(inner_w)
        }.animatedAppearance()
    }
    
    @ViewBuilder func InvestmentsSummary(_ width:CGFloat) -> some View{
        Container(width: width) { w in
            MainTextSubHeading(heading: "Invested Capital", subHeading: self.context.userAssets.InvestedValue.ToPrettyMoney(), headingSize: 13.5, subHeadingSize: 22.5, headColor: .white.opacity(0.5), subHeadColor: .white, headingWeight: .semibold, bodyWeight: .medium)
            
            if let profitableAsset = self.profitableAsset{
                self.assetInvestmentSummary(heading:"Most Profitable Asset",asset: profitableAsset,inner_w: w)
                    .padding(.vertical,5)
            }
            
            if let leastProfitableAsset = self.leastProfitableAsset{
                self.assetInvestmentSummary(heading:"Least Profitable Asset",asset: leastProfitableAsset,inner_w: w)
                    .padding(.vertical,5)
            }
        }
        .frame(width: width, alignment: .center)
        .borderCard(color:.white,clipping: .roundClipping)
    }
    
    @ViewBuilder func TopThreeMovers(_ width:CGFloat) -> some View{
        if self.assets.count >= 3{
            Container(width: width,aligment: .center,spacing:0) { inner_w in
                ForEach(Array(self.assets.sorted(by: {abs($0.Change) > abs($1.Change)})[0...2].enumerated()),id:\.offset){ _asset in
                    let asset = _asset.element
                    let idx = _asset.offset
                    Group{
                        if idx != 0{
                            Rectangle()
                                .foregroundColor(.white.opacity(0.2))
                                .frame(width: inner_w - 30,height: 2.5)
                        }
                        Container(width:inner_w,orientation: .horizontal){w in
                            
                            MainText(content: "\(idx+1)", fontSize: 30, color: .white.opacity(0.45), fontWeight: .semibold)
                            MainText(content: asset.Currency, fontSize: 20, color: .white, fontWeight: .medium)
                            Spacer()
                            PercentChangeView(value: asset.Change)
                        }

                    }
                }
            }
            .borderCard(color:.white,clipping: .roundClipping)
//            .padding(.horizontal,15)
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
                            PortfolioCard(asset: asset, w: w * 0.65,chartHeight: totalHeight * 0.1)
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
