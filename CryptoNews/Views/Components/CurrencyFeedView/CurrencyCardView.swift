//
//  CurrencyCardView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/10/2021.
//

import SwiftUI

class CurrencySelectorPreference:PreferenceKey{
    
    static var defaultValue:CrybseCoinPrice? = nil
    
    static func reduce(value: inout CrybseCoinPrice?, nextValue: () -> CrybseCoinPrice?) {
        value = nextValue()
    }
    
    
}

struct CurrencyViewButtonModifier:ViewModifier{
    var large:Bool
    @ViewBuilder func body(content: Content) -> some View {
        if large{
            content
                .padding(10)
                .frame(width: 150, height: 150, alignment: .center)
                .background(Color.mainBGColor.opacity(0.5))
                .clipContent(clipping: .roundClipping)
        }else{
            content
                .padding(10)
                .aspectRatio(contentMode: .fit)
                .background(Color.mainBGColor.opacity(0.5))
                .clipContent(clipping: .roundClipping)
        }
        
    }
}


struct CurrencyCard:View{
    var coin:CrybseCoin
    var large:Bool
    var onTap:() -> Void
    
    init(coin:CrybseCoin,large:Bool = false,onTap:@escaping () -> Void){
        self.coin = coin
        self.large = large
        self.onTap = onTap
    }
    
    var sym:String{
        return self.coin.Symbol
    }
    
    var width:CGFloat{
        return large ? 100 : 30
    }
    
    var body: some View{
        VStack(alignment: .center, spacing: 5) {
            CurrencySymbolView(currency: sym, size: .medium, width: self.width)
            MainText(content: sym, fontSize: 10, color: .white, fontWeight: .regular, style: .normal)
                .lineLimit(1)
                .frame(minWidth:width,maxWidth:50, alignment: .center)
        }.modifier(CurrencyViewButtonModifier(large: large))
        .buttonify(handler: self.onTap)
    }
    
}


struct CurrencyCardView: View {
    @StateObject var CoinsAPI:CrybseCoinsAPI
    var width:CGFloat
    var large:Bool
    @State var currency:CrybseCoin = .init()
    @State var price:CrybseCoinPrice? = nil

    init(width:CGFloat = totalWidth,large:Bool = false){
        self._CoinsAPI = .init(wrappedValue: .init())
        self.large = large
        self.width = width
    }
    
    var body: some View {
        Container(width: self.width, ignoreSides: width < totalWidth) { w in
            if !large{
                self.Horizontal_CurrencyView(w: w)
            }else{
                self.VGrid_Currency_View(w: w)
            }
            
        }.onAppear(perform: self.onAppear)
            .onChange(of: self.currency.Symbol, perform: self.getPriceforChoosenCurrency(sym:))
            .preference(key: CurrencySelectorPreference.self, value: self.price)
    }
}





extension CurrencyCardView{
    
    var currency_data: [CrybseCoin]{
        return  self.CoinsAPI.coins
    }
    
    
    func Horizontal_CurrencyView(w:CGFloat) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 7.5) {
                ForEach(Array(self.currency_data.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    CurrencyCard(coin: data) {
                        DispatchQueue.main.async {
                            self.currency = data
                        }
                    }
                }
            }
        }.frame(height: 75, alignment: .center)
    }
    
    
    func VGrid_Currency_View(w:CGFloat) -> some View{
        LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 150), spacing: 5, alignment: .center)], alignment: .center, spacing: 5) {
            ForEach(Array(self.currency_data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                CurrencyCard(coin: data) {
                    DispatchQueue.main.async {
                        self.currency = data
                    }
                }
            }
        }.frame(width: w)
    }
    
    
    func onAppear(){
        if self.CoinsAPI.coins.isEmpty{
            self.CoinsAPI.getCoins()
        }
    }
    
    func getPriceforChoosenCurrency(sym:String?){
        guard let sym = sym else {return}
        CrybsePriceAPI.shared.getSinglePrice(curr: sym) { price in
            if let price = price {
                let newPrice = CrybseCoinPrice()
                newPrice.USD = price.close
                newPrice.Currency = sym
                self.price = newPrice
            }
        }
    }

}

struct CurrencyCardView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyCardView(large: false)
//            .padding(.vertical)
            .background(Color.mainBGColor)
            .ignoresSafeArea()
    }
}
