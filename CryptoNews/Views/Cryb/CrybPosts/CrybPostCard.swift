//
//  CrybPostCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/12/2021.
//

import SwiftUI

struct CrybPostCard: View {
    
    @EnvironmentObject var context:ContextData
    var postData:CrybPostData
    var cardWidth:CGFloat = .zero
    @State var width:CGFloat = totalWidth
    @State var showMore:Bool = false
    @State var showAnalysis:Bool = false
    
    
    init(data:CrybPostData,cardWidth:CGFloat){
        self.postData = data
        self.cardWidth = cardWidth
    }
    
    
    func view(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return VStack(alignment:.center,spacing: 20){
            self.header
            self.mainBody
            self.footer
        }
    }
    
    var body: some View {
        Container(width: self.cardWidth, ignoreSides: false) { w in
            self.view(w: w)
        }.background(Color.white.opacity(0.35).overlay(BlurView.thinLightBlur))
        .clipContent(clipping: .roundClipping)
    }
}

extension CrybPostCard{
    
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
    var graphChart:some View{
        CurveChart(data: self.postData.PricePrediction.GraphData, interactions: false, size: .init(width: self.width * 0.5, height: 75), bg: .clear, chartShade: true)
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.postData.User.Img, width: self.img_width, height: self.img_width, contentMode: .fill, alignment: .center,clipping: .circleClipping)
            MainSubHeading(heading: self.postData.User.UserName, subHeading: self.postData.PricePrediction.Time.stringDate(), headingSize: 15, subHeadingSize: 13, headColor: .black, subHeadColor: .gray,alignment: .leading)
            Spacer()
        }.frame(width: self.width, alignment: .leading)
    }
    
    var mainBody:some View{
        MainText(content: self.postData.PostMessage, fontSize: 15, color: .black, fontWeight: .semibold)
            .padding(.horizontal,10)
            .frame(width: self.width,alignment: .leading)
    }
   
    var cryptoSection:some View{
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                CurrencySymbolView(currency: self.postData.Coin, size: .medium, width: self.img_width * 0.75)
                MainText(content: self.postData.Coin, fontSize: 15, color: .black, fontWeight: .regular)
            }
            Spacer()
            if !self.postData.PricePrediction.GraphData.isEmpty{
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
                    MainSubHeading(heading: "Low", subHeading: self.postData.PricePrediction.Low.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .black, alignment: .leading)
                    Spacer()
                    MainSubHeading(heading: "High", subHeading: self.postData.PricePrediction.High.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .black, alignment: .trailing)
                }
            }.frame(width: w, alignment: .center)
            MainText(content: "C", fontSize: 7, color: .black,fontWeight: .semibold,addBG: true,padding: 4.5)
                .clipContent(clipping: .circleClipping)
                .offset(x: CGFloat(self.postData.PricePrediction.NormalizedPricePercent) * w,y: -5)
            MainText(content: "O", fontSize: 7, color: .black,fontWeight: .semibold,addBG: true,padding: 4.5)
                .clipContent(clipping: .circleClipping)
                .offset(x: CGFloat(self.postData.PricePrediction.NormalizedPricePercent) * 0.65 * w,y: -5)
        }
        
        return VStack(alignment: .leading, spacing: 10) {
            MainText(content: "Prediction", fontSize: 14, color: .black, fontWeight: .semibold)
            view
            HStack(alignment: .center, spacing: 10) {
                MainSubHeading(heading: "O : Open Market Price", subHeading: self.postData.PricePrediction.Price.ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
                MainSubHeading(heading: "C : Close Market Price", subHeading: (self.postData.PricePrediction.Price * 0.98).ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
            }
        }
        
    }
    
    func RatingsMeter(header:String,percent:Float,w:CGFloat) -> some View{
        let subHeading:String = percent > 60 ? "Very Likely" : percent > 40 ? "Likely" : "Unlikely"
        let color:Color = percent > 60 ? .green : percent > 40 ? .orange : .red
        return HStack(alignment: .center, spacing: 10) {
            CircleChart(percent: percent, size: .init(width: w * 0.35, height: w * 0.35))
            MainSubHeading(heading: header, subHeading: subHeading, headingSize: 12, subHeadingSize: 14, headColor: .black, subHeadColor: color, alignment: .leading)
        }.padding(.top,20)
    }

    
    var footer:some View{
        let w_el = self.width * 0.5 - 5
        return LazyVStack(alignment: .leading, spacing: 15) {
            self.cryptoSection
//            self.cryptoScale
            LazyVGrid(columns: [.init(.adaptive(minimum: w_el, maximum: w_el), alignment: .leading)], alignment: .center, spacing: 10) {
                self.RatingsMeter(header: "Cryb. Rating", percent: 60,w: w_el)
//                    .frame(width: w_el, alignment: .topLeading)
                self.RatingsMeter(header: "Audience Rating", percent: 75,w: w_el)
//                    .frame(width: w_el, alignment: .topTrailing)
            }.frame(width: self.width, alignment: .leading)
            SystemButton(b_content: "Analysis →", haveBG: false, bgcolor: .white, alignment: .horizontal, borderedBG: true) {
                self.context.selectedPost = self.postData
            }.frame(width: self.width, alignment: .trailing)
        }
    }
    
}

struct CrybPostCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            Color.mainBGColor
            CrybPostCard(data: .test,cardWidth: totalWidth - 20)
        }.ignoresSafeArea()
    }
}
