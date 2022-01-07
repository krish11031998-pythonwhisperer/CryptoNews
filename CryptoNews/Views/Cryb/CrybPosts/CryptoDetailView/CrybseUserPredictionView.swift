//
//  CrybseUserPredictionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CrybseUserPredictionView: View {
    
    var width:CGFloat
    var postData:CrybPostData
    
    init(postData:CrybPostData,width:CGFloat = totalWidth - 30){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        Container(heading: "Prediction", headingDivider: false,headingSize: 18, width: self.width, ignoreSides: true,horizontalPadding: 0) { _ in
            self.cryptoScale
            HStack(alignment: .center, spacing: 10) {
                self.chartLegendBox(heading: "O : Open Market Price", subHeading: self.postData.PricePrediction.Price.ToMoney())
                self.chartLegendBox(heading: "C : Close Market Price", subHeading: (self.postData.PricePrediction.Price * 0.98).ToMoney())
            }.frame(width: self.width, alignment: .leading)
            self.userPredictionMarket
        }
    }
}

extension CrybseUserPredictionView{
    var cryptoScale:some View{
        let w = self.width
        let view = ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 5) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.mainBGColor)
                    .frame(width: w, height: 5, alignment: .center)
                HStack(alignment: .center, spacing: 10) {
                    self.chartIndicators(heading: "Low", subHeading: self.postData.PricePrediction.Low.ToMoney())
                    Spacer()
                    self.chartIndicators(heading: "High", subHeading: self.postData.PricePrediction.High.ToMoney())
                }
            }.frame(width: w, alignment: .center)
            self.lineChartAnnotations(heading: "C", offsetVal: CGFloat(self.postData.PricePrediction.NormalizedPricePercent) * w , w: w)
            self.lineChartAnnotations(heading: "C", offsetVal: CGFloat(self.postData.PricePrediction.NormalizedPricePercent) * 0.65 * w , w: w)
        }
        
        return view
        
    }
    
    func chartIndicators(heading:String,subHeading:String) -> some View{
        MainSubHeading(heading: heading, subHeading:subHeading, headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .white, alignment: .leading)
    }
    
    func chartLegendBox(heading:String,subHeading:String) -> some View{
        MainSubHeading(heading: heading, subHeading: subHeading, headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
            .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
    }
    
    func lineChartAnnotations(heading:String,offsetVal:CGFloat,w:CGFloat) -> some View{
        MainText(content: heading, fontSize: 7, color: .black,fontWeight: .semibold,addBG: true,padding: 4.5)
            .clipContent(clipping: .circleClipping)
            .offset(x:offsetVal,y: -5)
    }
    
    
    var userPredictionMarket:some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "User's Market Prediction", fontSize: 15, color: .white, fontWeight: .medium)
            Spacer()
            MainText(content: "Bull 🐂", fontSize: 20, color: .green, fontWeight: .semibold)
        }.blobify(color: .init(BlurView.regularBlur), clipping: .roundCornerMedium)
            .padding(.vertical,10)
    }
}

//struct CrybseUserPredictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CrybseUserPredictionView()
//    }
//}
