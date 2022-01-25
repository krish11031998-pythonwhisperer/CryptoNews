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
    @State var priceColor:Color = .black
    var w:CGFloat
    
    init(asset:CrybseAsset,w:CGFloat = .zero){
        self.asset = asset
        if let safePrice = asset.Price{
            self._price = .init(wrappedValue: safePrice)
        }
        
        self.w = w
    }
    
    var innerViewSize:CGSize{
        return .init(width: w, height: totalHeight * 0.3)
    }
    
    func assetHeaderInfo(w:CGFloat) -> some View{
        Container(width:w,ignoreSides: false ,horizontalPadding: 7.5,verticalPadding: 0) { _ in
            HStack(alignment: .center, spacing: 10) {
                MainText(content: self.asset.Currency, fontSize: 25, color: .black,fontWeight: .medium)
                Spacer()
                CurrencySymbolView(currency: self.asset.Currency, width: 30)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 0)
            }
        }.frame(width: w, alignment: .center)
    }
    
    var coinStats:[String:String]{
        return [
                "Change":(self.asset.Change).ToDecimals()+"%",
                "Rank":"\(self.asset.Rank)"
        ]
    }
    
    var financialSummaryKeyValues:[String:String]{
        return [
                "Market Cap":(self.asset.MarketCap).ToMoney(),
                "Value":self.asset.Value.ToMoney(),
                "Profit":self.asset.Profit.ToMoney(),
                "Asset Quantity":self.asset.CoinTotal.ToDecimals()
        ]
    }
    
    func summaryViewGenerator<T:View>(heading:String,@ViewBuilder innerView: @escaping (CGFloat) -> T) -> some View{
        Container(heading: heading, headingColor: .black, headingDivider: false, headingSize: 15, width: w,ignoreSides: false, horizontalPadding: 15,innerView: innerView)
            .frame(width: w, height: innerViewSize.height, alignment: .center)
    }
    
    @ViewBuilder func marketSummary(_ inner_w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: self.asset.Change.ToDecimals()+"%", subHeading: (self.asset.Price ?? 0).ToMoney(), headingSize: 13, subHeadingSize: 18, headColor: self.asset.Change > 0 ? .green : .red, subHeadColor: self.priceColor, orientation: .vertical, alignment: .topLeading)
            Spacer()
            MainText(content: "Rank #\(self.asset.Rank)", fontSize: 12, color: .black, fontWeight: .semibold)
                .blobify(color: AnyView(Color.clear), clipping: .roundCornerMedium)
        }
        .frame(width: inner_w,height: self.innerViewSize.height * 0.1, alignment: .topLeading)
        
        if let sparkline = self.asset.coinData?.Sparkline{
            CurveChart(data: sparkline,interactions: false, size: .init(width: inner_w, height: self.innerViewSize.height * 0.75), bg: .clear)
        }else{
            MainText(content: "No Chart", fontSize: 15, color: .black).frame(width: inner_w, alignment: .center)
        }
    }
    
    @ViewBuilder func moreInfoSummary(_ inner_w:CGFloat) -> some View{
        VStack{
            Spacer(minLength: 0)
            ForEach(Array(self.financialSummaryKeyValues.keys.sorted().enumerated()),id: \.offset){ _key in
                let key = _key.element
                let idx = _key.offset
                let value = self.financialSummaryKeyValues[key] ?? "No Value"
                
                HStack(alignment: .center, spacing: 10) {
                    MainText(content: key+":", fontSize: 15, color: .gray, fontWeight: .semibold)
                    Spacer()
                    MainText(content: value, fontSize: 18, color: .black, fontWeight: .medium)
                }
                .frame(width: inner_w, alignment: .leading)
                if idx < self.financialSummaryKeyValues.count - 1{
                    Divider().frame(width: 15, alignment: .topLeading)
                }
            }
            Spacer(minLength: 0)
        }.frame(width: inner_w, alignment: .topLeading)
    }
    
    
    func handleOnTap(){
        if self.context.selectedCurrency?.Currency != self.asset.Currency{
            setWithAnimation {
                self.context.selectedCurrency = self.asset
            }
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
    
    func dynamicInnerView(w:CGFloat) -> some View{
        
        let buttonText = self.switchView ? "←" : "Quick Info  →"
        
        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .center) {
                if !self.switchView{
                    self.summaryViewGenerator(heading: "Market Summary", innerView: self.marketSummary(_:))
                        .opacity(!self.switchView ? 1 : 0)
                }else{
                    self.summaryViewGenerator(heading: "Financial Summary", innerView: self.moreInfoSummary(_:))
                        .opacity(self.switchView ? 1 : 0)
                        .rotation3DEffect(.degrees(-180), axis: (x: 0.5,y:0.0,z:0.0))
                }
            }
            .frame(width: w, height: innerViewSize.height, alignment: .center)
            .padding(.top,10)
            .flipRotation(rotate: $switchView)
            HStack(alignment: .center, spacing: 10) {
                TabButton(title: buttonText, fontSize: 7.5, textColor: .white, flexible: true) {
                    self.switchView.toggle()
                }
                Spacer()
                TabButton(title: "More  →", fontSize: 7.5, textColor: .white, flexible: true,action: self.handleOnTap)
            }.padding(.horizontal,7.5)
        }
        
    }
    
    func updateAsset(_ newAsset:CrybseAsset) {
        guard let selectedAsset = self.context.selectedCurrency, selectedAsset.Currency == self.asset.Currency && self.asset.Currency == newAsset.Currency else {return}
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
    
    
    var body: some View {
        Container(width: w, horizontalPadding: 7.5, verticalPadding: 15, orientation: .vertical) { w in
            self.assetHeaderInfo(w: w)
            self.dynamicInnerView(w: w)
        }
        .frame(width: w, alignment: .center)
        .background(mainLightBGView.overlay(BlurView.thinLightBlur.opacity(0.25)))
        .clipContent(clipping: .roundClipping)
        .onReceive(self.asset.coinData!.$price, perform: self.updatePrice(_:))
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
