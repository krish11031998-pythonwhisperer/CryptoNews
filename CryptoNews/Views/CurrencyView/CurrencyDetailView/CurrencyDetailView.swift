//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct CurrencyDetailView: View {
    var currency:AssetData
    
    init(info:AssetData){
        self.currency = info
    }
    
    var curveChart:some View{
        CurveChart(data: self.currency.timeSeries?.compactMap({$0.price}) ?? [])
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            self.curveChart
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct CurrencyDetailView_Previews: PreviewProvider {
    
    
    @StateObject static var news:AssetAPI = .init(currency: "XRP")
    
    
    static func onAppear(){
        if self.news.data == nil{
            self.news.getAssetInfo()
        }
    }
    static var previews: some View {
        ZStack(alignment: .center) {
            if let data = CurrencyDetailView_Previews.news.data{
                CurrencyDetailView(info: data)
            }else{
                ProgressView()
            }
        }.onAppear(perform:CurrencyDetailView_Previews.onAppear)
        
    }
}
