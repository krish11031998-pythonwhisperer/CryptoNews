//
//  PortfolioCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 14/01/2022.
//

import SwiftUI

struct PortfolioCard: View {
    @EnvironmentObject var context:ContextData
    @ObservedObject var asset:CrybseAsset
    @State var price:Float = .zero
    @State var switchView:Bool = false
    @State var priceColor:Color = .white
    var selected:Bool
    var chartSize:CGSize = .zero
    var w:CGFloat
    var h:CGFloat
    
    init(asset:CrybseAsset,w:CGFloat = .zero, chartHeight h:CGFloat = totalHeight * 0.25,selected:Bool = false){
        self.asset = asset
        self.chartSize  = .init(width: w * 0.5, height: h * 0.5)
        if let safePrice = asset.Price{
            self._price = .init(wrappedValue: safePrice)
        }
        self.selected = selected
        self.h = h - 2
        self.w = w - 2
    }
    
    var headerHeight:CGFloat{
        return self.h * 0.25
    }
    
    var footerHeight:CGFloat{
        return self.h * 0.25
    }
    
    var marketHeight:CGFloat{
        return self.h * 0.5
    }
    
    func assetHeaderInfo(w:CGFloat) -> some View{
        return
        Container(width:w,ignoreSides: true,verticalPadding: 0,spacing: 0){ _ in
            Container(width:w,ignoreSides: true,verticalPadding: 0,orientation: .horizontal) { _ in
                MainText(content: self.asset.Currency, fontSize: 25, color: .white,fontWeight: .medium)
                Spacer()
                if self.selected{
                    Color(hex: self.asset.Color)
                        .frame(width: 30, height: 30, alignment: .center)
                        .clipContent(clipping: .circleClipping)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 0)
                }
            }
            MainTextSubHeading(heading: self.asset.Change.ToDecimals()+"%", subHeading: (self.asset.Price ?? 0).ToMoney(), headingSize: 13, subHeadingSize: 18, headColor: self.asset.Change > 0 ? .green : .red, subHeadColor: .white, orientation: .vertical, alignment: .topLeading)
        }.frame(width: w, height: self.headerHeight, alignment: .center)
    }
    
    var coinStats:[String:String]{
        return [
            "Change":(self.asset.Change).ToDecimals()+"%",
            "Rank":"\(self.asset.Rank)"
        ]
    }
    
    var financialSummaryKeyValues:[String:(String,Color)]{
        return [
            "Value":(self.asset.Value.ToMoney(),.white),
            "Profit":(abs(self.asset.Profit).ToMoney(),self.asset.Profit > 0 ? .green : self.asset.Profit < 0 ? .red : .white),
            "Quantity":(self.asset.CoinTotal.ToDecimals(),.white),
            "HODL Ratio":(self.percent.ToDecimals() + "%",.init(hex: self.asset.Color))
        ]
    }
    
    func summaryViewGenerator<T:View>(heading:String,w:CGFloat,@ViewBuilder innerView: @escaping (CGFloat) -> T) -> some View{
        Container(heading: heading, headingColor: .black, headingDivider: false, headingSize: 15, width: w,ignoreSides: false, horizontalPadding: 7.5,verticalPadding: 0,spacing: 5,innerView: innerView)
    }
    
    @ViewBuilder func marketSummary(_ inner_w:CGFloat) -> some View{
        if !self.asset.CoinData.Sparkline.isEmpty{
            CurveChart(data: Array(self.asset.CoinData.Sparkline[(self.asset.CoinData.Sparkline.count - 10)...]),interactions: false, size: .init(width: inner_w, height: self.marketHeight), bg: .clear)
        }else{
            MainText(content: "No Chart", fontSize: 15, color: .black,fontWeight: .bold).frame(width: inner_w, alignment: .center)
                .frame(width: inner_w, height: self.marketHeight, alignment: .center)
                .background(Color.blue)
        }
    }

    func handleOnTap(){
        if self.context.selectedAsset?.Currency != self.asset.Currency{
            setWithAnimation {
                self.context.selectedAsset = self.asset
            }
        }
    }
    
    var percent:Float{
        let total = self.context.userAssets.trackedAssets.reduce(0, {$0 + $1.Value})
        return (self.asset.Value/total) * 100
    }
    
    @ViewBuilder func footer(_ inner_w:CGFloat) -> some View{
        Container(width: inner_w, ignoreSides: true,verticalPadding: 0) { w in
            if self.selected{
                MainText(content: self.asset.Value.ToPrettyMoney(), fontSize: 18, color: .white, fontWeight: .semibold)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .right) {
                        Spacer()
                        PercentChangeView(value: self.asset.Profit/self.asset.Value,type: "small")
                    }
                
            }
            MainText(content: self.percent.ToDecimals() + "%", fontSize: 15, color: .gray, fontWeight: .medium)
                .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .right) {
                    MainText(content: " of your holdings", fontSize: 13, color: .gray, fontWeight: .regular)
                }
        }.frame(width: inner_w, height: self.footerHeight, alignment: .center)
    }
    
    func updatePrice(_ newPrice:Float?){
        guard let safeAssetPrice = self.asset.Price, let safeNewPrice = newPrice else {return}
        setWithAnimation {
            if safeAssetPrice > safeNewPrice{
                self.priceColor = .red
            }else if safeAssetPrice <= safeNewPrice{
                self.priceColor = .green
            }
        }
    }
    
    
    func resetPriceColor(_ color:Color){
        if color != .black{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                withAnimation(.easeInOut){
                    self.priceColor = .black
                }
            }
        }
    }
    
    func updateAsset(_ newAsset:CrybseAsset) {
        guard let selectedAsset = self.context.selectedAsset, selectedAsset.Currency == self.asset.Currency && self.asset.Currency == newAsset.Currency else {return}
        if self.asset.Price != selectedAsset.Price{
            self.asset.Price = selectedAsset.Price
        }
        
        if self.asset.Profit != selectedAsset.Profit{
            self.asset.Profit = selectedAsset.Profit
        }
        
        if self.asset.Value != selectedAsset.Value{
            self.asset.Value = selectedAsset.Value
        }
    }
    
    
    @ViewBuilder var activateBG:some View{
        if self.selected{
            ZStack(alignment: .center) {
                Color.linearGradient(colors: [Color(hex: self.asset.Color).opacity(0.65),Color.clear,Color.clear], start: .topLeading, end: .bottomTrailing)
            }
        }else{
            Color.clear
        }
    }
    
    
    var body: some View {
        Container(width: w, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical,spacing:0) { w in
            self.assetHeaderInfo(w: w)
            self.marketSummary(w)
            self.footer(w)
        }
        .basicCard(background:self.activateBG.anyViewWrapper())
        .borderCard(color: .init(hex: self.asset.Color))
        .buttonify(handler: self.handleOnTap)
        .onReceive(self.asset.CoinData.$current_price, perform: self.updatePrice(_:))
        .onChange(of: self.priceColor, perform: self.resetPriceColor(_:))
    }
}

struct PortfolioCardTester:View{
    @StateObject var coin:CrybseAssetsAPI
    var curr:String
    init(curr:String){
        self.curr = curr
        self._coin = .init(wrappedValue: .init(symbols: [curr], uid: "jV217MeUYnSMyznDQMBgoNHfMvH2"))
    }
    
    var firstCurr:CrybseAsset?{
        return self.coin.coinsData?.trackedAssets.filter({$0.currency == self.curr}).first ?? self.coin.coinsData?.watchingAssets.filter({$0.currency == self.curr}).first
    }
    
    var body: some View{
        ZStack(alignment: .center) {
            mainBGView
            if let safeAsset = self.firstCurr{
                PortfolioCard(asset: safeAsset,w: totalWidth - 50)
            }else{
                ProgressView()
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            .ignoresSafeArea()
            .onAppear {
                self.coin.getAssets()
            }
            
    }
}

struct PortfolioCard_Previews: PreviewProvider {
    static var previews: some View {
       PortfolioCardTester(curr: "SOL")
    }
}
