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
    var w:CGFloat
    var h:CGFloat
    
    init(asset:CrybseAsset,w:CGFloat = .zero,h:CGFloat = totalHeight * 0.25,selected:Bool = false){
        self.asset = asset
        if let safePrice = asset.Price{
            self._price = .init(wrappedValue: safePrice)
        }
        self.selected = selected
        self.h = h
        self.w = w
    }
    
    var innerViewSize:CGSize{
        return .init(width: w, height: h - 20)
    }
    
    func assetHeaderInfo(w:CGFloat) -> some View{
        let h = self.innerViewSize.height * 0.2
        return Container(width:w,ignoreSides: true,orientation: .horizontal) { _ in
            MainText(content: self.asset.Currency, fontSize: 25, color: .white,fontWeight: .medium)
            Spacer()
            CurrencySymbolView(currency: self.asset.Currency, width: 30)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 0)
        }.frame(width: w,height:h, alignment: .center)
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
        let h = self.innerViewSize.height * (self.selected ? 0.5 : 0.6) - 5
        VStack(alignment: .leading, spacing: 0) {
            Container(width: inner_w,ignoreSides: true,verticalPadding: 0, orientation: .horizontal) { _ in
                MainSubHeading(heading: self.asset.Change.ToDecimals()+"%", subHeading: (self.asset.Price ?? 0).ToMoney(), headingSize: 13, subHeadingSize: 18, headColor: self.asset.Change > 0 ? .green : .red, subHeadColor: .white, orientation: .vertical, alignment: .topLeading)
                Spacer()
                MainText(content: "#\(self.asset.Rank)", fontSize: 12, color: .white, fontWeight: .semibold)
                    .blobify(color: AnyView(Color.clear), clipping: .roundCornerMedium)
            }
            .frame(width: inner_w,height: h * 0.4, alignment: .topLeading)
            if let sparkline = self.asset.coinData?.Sparkline{
                CurveChart(data: sparkline,interactions: false, size: .init(width: inner_w, height: h * 0.6), bg: .clear)
            }else{
                MainText(content: "No Chart", fontSize: 15, color: .black).frame(width: inner_w, alignment: .center)
            }
        }.frame(width: inner_w, height: h, alignment: .topLeading)
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
        if self.selected{
            LazyVGrid(columns: [.init(.adaptive(minimum: inner_w * 0.5 - 5, maximum: inner_w * 0.5), spacing: 10, alignment: .center)], alignment: .center, spacing: 10) {
                ForEach(self.financialSummaryKeyValues.keys.sorted(),id:\.self){ key in
                    if let value = self.financialSummaryKeyValues[key]{
                        MainSubHeading(heading: key, subHeading: value.0, headingSize: 12, subHeadingSize: 13.5, headColor: .white.opacity(0.5), subHeadColor: value.1, orientation: .vertical, headingWeight: .regular, bodyWeight: .medium, spacing: 2.5, alignment: .center)
                    }
                }
            }.frame(width: inner_w, height: self.innerViewSize.height * 0.3, alignment: .center)
        }else{
            Container(width: inner_w, ignoreSides: true, orientation: .horizontal,spacing: 5) { _  in
                MainText(content: self.percent.ToDecimals() + "%", fontSize: 15, color: .gray, fontWeight: .medium)
                MainText(content: " of your holdings", fontSize: 13, color: .gray, fontWeight: .regular)
            }.frame(width: inner_w, height: self.innerViewSize.height * 0.2, alignment: .center)
        }
        
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
    
    
    var activateBG:AnyView{
        return self.selected ? Color.linearGradient(colors: [Color(hex: self.asset.Color),Color.clear,Color.clear], start: .topLeading, end: .bottomTrailing).anyViewWrapper() : Color.clear.anyViewWrapper()
    }
    
    
    var body: some View {
        Container(width: w, horizontalPadding: 10, verticalPadding: 10, orientation: .vertical,spacing:0) { w in
            self.assetHeaderInfo(w: w)
            self.marketSummary(w)
            self.footer(w)
        }
        .basicCard(background:self.activateBG)
        .borderCard(color: .init(hex: self.asset.Color))
        .buttonify(handler: self.handleOnTap)
        .onReceive(self.asset.coinData!.$price, perform: self.updatePrice(_:))
        .onChange(of: self.priceColor, perform: self.resetPriceColor(_:))
        .padding(.top,5)
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
