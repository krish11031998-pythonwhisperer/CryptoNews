//
//  CrybseUserPredictionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CrybseCrybotPredictionView: View {
    
    var width:CGFloat
    var postData:CrybPostData
    @State var chartIndicator:Int = -1
    
    init(postData:CrybPostData,width:CGFloat = totalWidth - 30){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        Container(heading: "Crybot's Prediction", headingDivider: false,headingSize: 18, width: self.width, ignoreSides: true,horizontalPadding: 0) { _ in
            let size = CGSize(width: self.width, height: 150)
            let cryb_prediction = self.crybPredictedData[self.indicator]
            MainSubHeading(heading: "Value", subHeading: cryb_prediction.ToMoney(), headingSize: 13, subHeadingSize: 15, headColor: .gray, subHeadColor: .white, alignment: .leading)
                .frame(width: self.width, alignment: .leading)
            
            CurveChart(data: self.postData.PricePrediction.GraphData, choosen: self.$chartIndicator, interactions: true, size: size, bg: .clear)
            self.PredictionView
        }
    }
}

extension CrybseCrybotPredictionView{
    var crybPredictedData:[Float]{
        self.postData.PricePrediction.GraphData.map({$0 + Float.random(in: -50...50)})
    }
    
    var indicator:Int{
        return self.chartIndicator != -1 ? self.chartIndicator : 0
    }
    
    var PredictionView:some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "Crybot's Market Prediction", fontSize: 15, color: .white, fontWeight: .medium)
            Spacer()
            MainText(content: "Bear 🐻", fontSize: 20, color: .red, fontWeight: .semibold)
        }.blobify(color: .init(BlurView.regularBlur), clipping: .roundCornerMedium)
    }
}

