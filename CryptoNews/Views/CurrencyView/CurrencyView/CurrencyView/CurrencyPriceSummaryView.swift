//
//  CurrencyPriceSummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/02/2022.
//

import SwiftUI

struct CurrencyPriceSummaryView: View {
    var asset:CrybseAsset
    @Binding var choosenPrice:Int
    @Binding var choosenInterval:String
    @Binding var refresh:Bool
    @Namespace var animation
    var width:CGFloat
    
    init(asset:CrybseAsset,width:CGFloat = totalWidth,choosenPrice:Binding<Int>,choosenInterval:Binding<String>,refresh:Binding<Bool>){
        self.asset = asset
        self.width = width
        self._refresh = refresh
        self._choosenPrice = choosenPrice
        self._choosenInterval = choosenInterval
    }
    
    var headerView:some View{
        HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "heart",b_content: "Follow",color: .white, haveBG: false, size: .init(width: 15, height: 15), bgcolor: .white, alignment: .vertical, borderedBG: false) {}
            Spacer()
            CurrencySymbolView(currency: self.asset.Currency,width: 50)
            Spacer()
            if self.refresh{
                ProgressView().frame(width: 50, alignment: .center)
            }else{
                RefreshTimerView(timeLimit: 100, refresh: $refresh)
            }
            
        }.frame(width: self.width, alignment: .center)
    }
    
    
    @ViewBuilder var curveChartView:some View{
        CurveChart(data: self.Prices.compactMap({$0.price}), choosen: self.$choosenPrice, interactions: true, size: .init(width: self.width, height: totalHeight * 0.25),bg: .clear, lineColor: nil, chartShade: true)
    }
    
    var color:Color?{
        guard let color = self.asset.coinData?.Color else {return nil}
        return Color(hex: color)
    }
    
    var timeSpan:Int{
        let hr = 12
        if self.choosenInterval == "3hr"{
            return hr * 3
        }else if self.choosenInterval == "6hr"{
            return hr * 6
        }else if self.choosenInterval == "24hr"{
            return hr * 24
        }
        return hr
    }
    
    var Prices:CrybseCoinPrices{
        guard let prices = self.asset.coin?.prices else {return []}
        let length = prices.count
        return length > self.timeSpan ? Array(prices[(length - self.timeSpan)...]) : prices
    }
    
    var choosenTimeIntervalView:some View{
        let intervals:[String] = ["1hr","3hr","6hr","24hr"]
        return HStack(alignment: .center, spacing: 10) {
            ForEach(Array(intervals.enumerated()),id:\.offset){ _interval in
                let interval = _interval.element
                let idx = _interval.offset

                MainText(content: interval, fontSize: 10, color: self.choosenInterval == interval ? .white : .white, fontWeight: .semibold,padding: 10)
                    .padding(10)
                    .background(
                        ZStack(alignment: .center){
                            if self.self.choosenInterval == interval{
                                BlurView
                                    .thinLightBlur
                            }
                        }.clipContent(clipping: .roundCornerMedium)
                    )
                    .buttonify {
                        self.choosenInterval = interval
                    }
                if idx != intervals.count - 1{
                    Spacer()
                }
            }
        }
        .animation(.easeInOut)
        .padding(10)
        .frame(width: self.width, alignment: .center)
        .background(BlurView.thinDarkBlur)
        .clipContent(clipping: .roundClipping)
    }
    
    var SelectedPrice:Float{
        if self.choosenPrice != -1{
            return self.Prices.compactMap({$0.Price})[self.choosenPrice]
        }else{
            return self.Prices.compactMap({$0.Price}).last ?? self.asset.Price ?? 0.0
        }
    }
    
    var CoinPriceView:some View{
        MainSubHeading(heading: self.asset.CoinData.Name, subHeading: self.SelectedPrice.ToMoney(), headingSize: 17.5, subHeadingSize: 25, headColor: .white, subHeadColor: .white, headingWeight: .medium, bodyWeight: .semibold, alignment: .center)
            .frame(width: self.width, alignment: .center)
    }

    var body: some View {
        Container(width: self.width, ignoreSides: true) { w in
            self.headerView
            self.CoinPriceView.padding(.vertical,25)
            self.curveChartView
            self.choosenTimeIntervalView
        }
    }
}

struct CurrencyPriceSummaryViewPreviewProvider:View{
    @StateObject var assetAPI:CrybseAssetsAPI
    @State var choosen:Int = -1
    @State var chooseInterval:String = "1hr"
    
    init(currencies:[String] = ["AVAX"],uid:String = "jV217MeUYnSMyznDQMBgoNHfMvH2"){
        self._assetAPI = .init(wrappedValue: .init(symbols: currencies, uid: uid))
    }
    
    
    func onAppear(){
        if self.assetAPI.coinsData == nil{
            self.assetAPI.getAssets()
        }
    }
    
    var asset:CrybseAsset?{
        return self.assetAPI.coinsData?.assets?["AVAX"]
    }
    
    var assetKeys:Array<String>{
        if let asset = self.assetAPI.coinsData?.assets {
            return [asset.keys.description]
        }
        return []
    }
    
    var body: some View{
        Group{
            if let safeAsset = self.asset{
                CurrencyPriceSummaryView(asset: safeAsset,width: totalWidth - 30,choosenPrice: $choosen,choosenInterval: $chooseInterval,refresh: .constant(false))
            }else{
                ProgressView()
            }
        }.onAppear(perform: self.onAppear)
    }
}

struct CurrencyPriceSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPriceSummaryViewPreviewProvider()
            .background(mainBGView.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
            
    }
}
