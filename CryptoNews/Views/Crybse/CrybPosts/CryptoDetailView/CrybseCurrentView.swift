//
//  CrybsePredictionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CrybseCurrentView: View {
    var width:CGFloat
    var postData:CrybPostData
    
    init(postData:CrybPostData,width:CGFloat = totalWidth - 30){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                CurrencySymbolView(currency: self.postData.Coin, size: .medium, width: self.img_width * 0.75)
                MainText(content: self.postData.Coin, fontSize: 15, color: .white, fontWeight: .regular)
            }
            Spacer()
            if !self.postData.PricePrediction.GraphData.isEmpty{
                self.graphChart
            }
        }.frame(width: self.width, alignment: .leading)
    }
}

extension CrybseCurrentView{
    var graphChart:some View{
        CurveChart(data: self.postData.PricePrediction.GraphData, interactions: false, size: .init(width: self.width * 0.5, height: 75), bg: .clear, chartShade: true)
    }
    
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
}

//struct CrybsePredictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CrybsePredictionView()
//    }
//}
