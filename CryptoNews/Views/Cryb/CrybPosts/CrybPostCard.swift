//
//  CrybPostCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/12/2021.
//

import SwiftUI

struct CrybPostCard: View {
    
    var postCardData:CrybPostData
    @State var width:CGFloat = .zero
    @State var showMore:Bool = false
    @State var showAnalysis:Bool = false
    
    func view(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width == .zero{
                self.width = w
            }
        }
        
        return VStack(alignment:.center,spacing: 20){
            self.header
            self.mainBody
//            if !self.postCardData.PricePrediction.GraphData.isEmpty{
//                self.graphChart
//            }
            self.footer
        }
    }
    
    var body: some View {
        Container(width: totalWidth - 20, ignoreSides: false) { w in
            self.view(w: w)
        }.background(Color.white.opacity(0.35).overlay(BlurView(style: .regular))).clipContent(clipping: .roundClipping)
    }
}

extension CrybPostCard{
    
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
    var graphChart:some View{
        CurveChart(data: self.postCardData.PricePrediction.GraphData, interactions: false, size: .init(width: self.width * 0.5, height: 75), bg: .clear, chartShade: true)
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.postCardData.User.Img, width: self.img_width, height: self.img_width, contentMode: .fill, alignment: .center,clipping: .circleClipping)
            MainSubHeading(heading: self.postCardData.User.UserName, subHeading: self.postCardData.PricePrediction.Time.stringDate(), headingSize: 15, subHeadingSize: 13, headColor: .black, subHeadColor: .gray,alignment: .leading)
            Spacer()
        }.frame(width: self.width, alignment: .leading)
    }
    
    var mainBody:some View{
        MainText(content: self.postCardData.PostMessage, fontSize: 15, color: .black, fontWeight: .semibold)
            .padding(.horizontal,10)
            .frame(width: self.width,alignment: .leading)
    }
   
    var cryptoSection:some View{
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                CurrencySymbolView(currency: self.postCardData.Coin, size: .medium, width: self.img_width * 0.75)
                MainText(content: self.postCardData.Coin, fontSize: 15, color: .black, fontWeight: .regular)
            }
            Spacer()
            if !self.postCardData.PricePrediction.GraphData.isEmpty{
                self.graphChart
            }
        }.frame(width: self.width, alignment: .leading)
    
    }
    
    var cryptoScale:some View{
        let w = self.width
        let view = ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 5) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.mainBGColor)
                    .frame(width: w, height: 5, alignment: .center)
                HStack(alignment: .center, spacing: 10) {
                    MainSubHeading(heading: "Low", subHeading: self.postCardData.PricePrediction.Low.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .black, alignment: .leading)
                    Spacer()
                    MainSubHeading(heading: "High", subHeading: self.postCardData.PricePrediction.High.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .black, alignment: .trailing)
                }
            }.frame(width: w, alignment: .center)
            MainText(content: "C", fontSize: 7, color: .black,fontWeight: .semibold,addBG: true,padding: 4.5)
                .clipContent(clipping: .circleClipping)
                .offset(x: CGFloat(self.postCardData.PricePrediction.NormalizedPricePercent) * w,y: -5)
            MainText(content: "O", fontSize: 7, color: .black,fontWeight: .semibold,addBG: true,padding: 4.5)
                .clipContent(clipping: .circleClipping)
                .offset(x: CGFloat(self.postCardData.PricePrediction.NormalizedPricePercent) * 0.65 * w,y: -5)
        }
        
        return VStack(alignment: .leading, spacing: 10) {
            MainText(content: "Prediction", fontSize: 14, color: .black, fontWeight: .semibold)
            view
            HStack(alignment: .center, spacing: 10) {
                MainSubHeading(heading: "O : Open Market Price", subHeading: self.postCardData.PricePrediction.Price.ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
                MainSubHeading(heading: "C : Close Market Price", subHeading: (self.postCardData.PricePrediction.Price * 0.98).ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
            }
        }
        
    }
    
    func RatingsMeter(header:String,percent:Float,w:CGFloat) -> some View{
        let subHeading:String = percent > 60 ? "Very Likely" : percent > 40 ? "Likely" : "Unlikely"
        return HStack(alignment: .center, spacing: 10) {
            CircleChart(percent: percent, size: .init(width: w * 0.35, height: w * 0.35))
            MainSubHeading(heading: header, subHeading: subHeading, headingSize: 12, subHeadingSize: 14, headColor: .gray, subHeadColor: .black, alignment: .leading)
        }.padding(.top,20)
    }

    
    var footer:some View{
        let w_el = self.width * 0.5 - 5
        return VStack(alignment: .leading, spacing: 15) {
            self.cryptoSection
            self.cryptoScale
            LazyVGrid(columns: [.init(.adaptive(minimum: w_el, maximum: w_el), alignment: .leading)], alignment: .center, spacing: 10) {
                self.RatingsMeter(header: "Cryb. Rating", percent: 60,w: w_el)
                    .frame(width: w_el, alignment: .topLeading)
                self.RatingsMeter(header: "Audience Rating", percent: 75,w: w_el)
                    .frame(width: w_el, alignment: .topTrailing)
            }.frame(width: self.width, alignment: .leading)
            MainText(content: "Analysis →", fontSize: 15, color: .white, fontWeight: .regular)
                .blobify(color: AnyView(Color.white.opacity(0.2)))
                .buttonify {
                    print("Analysis Clicked")
                }
                .padding(.vertical,15)
                .frame(width: self.width, alignment: .trailing)
        }
    }
    
}

struct CrybPostCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            Color.mainBGColor
            CrybPostCard(postCardData: .test)
        }.ignoresSafeArea()
    }
}
