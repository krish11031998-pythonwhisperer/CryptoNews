//
//  CrybPostDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/12/2021.
//

import SwiftUI

struct CrybPostDetailView: View {
    var postData:CrybPostData
    @State var width:CGFloat = .zero
    @State var chartIndicator:Int = 0
    @EnvironmentObject var context:ContextData
    
    init(postData:CrybPostData){
        self.postData = postData
    }
    
    func mainBodyGen(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return VStack(alignment: .leading, spacing: 25) {
            self.postBody
            self.cryptoSection
            self.cryptoScale
            self.ratingsView
            self.backers
        }.frame(width: w, alignment: .center)
    }
    
    func onClose(){
        if self.context.selectedPost != nil{
            withAnimation(.easeInOut) {
                self.context.selectedPost = nil
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(width: totalWidth,ignoreSides: false, horizontalPadding: 10,verticalPadding: 50,onClose: self.onClose) { w in
                self.mainBodyGen(w: w)
            }
        }
    }
}

extension CrybPostDetailView{
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
    var postBody:some View{

        Container(width: self.width, ignoreSides: false) { w in
            self.header(w: w)
            self.mainBody(w: w)
        }
        .frame(width: self.width, alignment: .center)
        .background(BlurView.thinLightBlur)
        .clipContent(clipping: .roundClipping)
    }
    
    func header(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.postData.User.Img, width: w * 0.15, height: w * 0.15, contentMode: .fill, alignment: .center,clipping: .circleClipping)
            MainSubHeading(heading: self.postData.User.UserName, subHeading: self.postData.PricePrediction.Time.stringDate(), headingSize: 15, subHeadingSize: 13, headColor: .black, subHeadColor: .gray,alignment: .leading)
            Spacer()
        }
    }
    
    func mainBody(w:CGFloat) -> some View{
        MainText(content: self.postData.PostMessage, fontSize: 15, color: .black, fontWeight: .semibold)
            .padding(.horizontal,10)
    }
    
    
    var cryptoSection:some View{
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                CurrencySymbolView(currency: self.postData.Coin, size: .medium, width: self.img_width * 0.75)
                MainText(content: self.postData.Coin, fontSize: 15, color: .white, fontWeight: .regular)
            }
            Spacer()
            if !self.postData.PricePrediction.GraphData.isEmpty{
                self.graphChart            }
        }.frame(width: self.width, alignment: .leading)
    
    }
    
    var graphChart:some View{
        CurveChart(data: self.postData.PricePrediction.GraphData, interactions: false, size: .init(width: self.width * 0.5, height: 75), bg: .clear, chartShade: true)
    }
    
    var crybPredictedData:[Float]{
        self.postData.PricePrediction.GraphData.map({$0 + Float.random(in: -50...50)})
    }
    
    var indicator:Int{
        return self.chartIndicator != -1 ? self.chartIndicator : 0
    }
    
    var predictedChartwDelta:some View{
        let size = CGSize(width: self.width, height: 150)
        let prediction = self.postData.PricePrediction.GraphData[self.indicator]
        let cryb_prediction = self.crybPredictedData[self.indicator]
        let percent:Float = 1 - cryb_prediction/prediction
        let txnPercent:(Float,Color,String) = percent > 0 ? (percent,.green,"arrowtriangle.up.fill") : (percent,.red,"arrowtriangle.down.fill")
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                MainSubHeading(heading: "Prediction", subHeading: prediction.ToMoney(), headingSize: 13, subHeadingSize: 15, headColor: .gray, subHeadColor: .white, alignment: .leading)
                MainSubHeading(heading: "Cryb Prediction", subHeading: cryb_prediction.ToMoney(), headingSize: 13, subHeadingSize: 15, headColor: .gray, subHeadColor: .white, alignment: .leading)
                Spacer()
                HStack(alignment: .center) {
                    Image(systemName: txnPercent.2)
                        .resizable()
                        .frame(width: 15, height: 15, alignment: .center)
                        .foregroundColor(.white)
                    MainText(content: txnPercent.0.ToDecimals() + "%", fontSize: 12, color: .white, fontWeight: .bold,style: .monospaced)
                }.padding()
                    .background(txnPercent.1)
                    .clipContent(clipping: .roundClipping)
            }
            
            CurveChart(data: self.postData.PricePrediction.GraphData, choosen: self.$chartIndicator, interactions: true, size: size, bg: .clear)
        }.padding(.vertical,10)
    }
    
    var cryptoScale:some View{
        let w = self.width
        let view = ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 5) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.mainBGColor)
                    .frame(width: w, height: 5, alignment: .center)
                HStack(alignment: .center, spacing: 10) {
                    MainSubHeading(heading: "Low", subHeading: self.postData.PricePrediction.Low.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .white, alignment: .leading)
                    Spacer()
                    MainSubHeading(heading: "High", subHeading: self.postData.PricePrediction.High.ToMoney(), headingSize: 9, subHeadingSize: 10, headColor: .gray, subHeadColor: .white, alignment: .trailing)
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
            MainText(content: "Prediction", fontSize: 18, color: .white, fontWeight: .semibold)
            view
            HStack(alignment: .center, spacing: 10) {
                MainSubHeading(heading: "O : Open Market Price", subHeading: self.postData.PricePrediction.Price.ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
                MainSubHeading(heading: "C : Close Market Price", subHeading: (self.postData.PricePrediction.Price * 0.98).ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
            }
            self.predictedChartwDelta
        }
        
    }
    
    var ratingsView:some View{
        let w_el = self.width * 0.5 - 5
        
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: "Rating", fontSize: 18, color: .white, fontWeight: .semibold)
            LazyVGrid(columns: [.init(.adaptive(minimum: w_el, maximum: w_el), alignment: .leading)], alignment: .center, spacing: 10) {
                self.RatingsMeter(header: "Cryb. Rating", percent: 60,w: w_el)
                self.RatingsMeter(header: "Audience Rating", percent: 75,w: w_el)
            }.frame(width: self.width, alignment: .leading)
        }
    }
    
    func RatingsMeter(header:String,percent:Float,w:CGFloat) -> some View{
        let subHeading:String = percent > 60 ? "Very Likely" : percent > 40 ? "Likely" : "Unlikely"
        return HStack(alignment: .center, spacing: 10) {
            CircleChart(percent: percent, size: .init(width: w * 0.35, height: w * 0.35))
            MainSubHeading(heading: header, subHeading: subHeading, headingSize: 12, subHeadingSize: 14, headColor: .gray, subHeadColor: .white, alignment: .leading)
        }.padding(.top,20)
    }

    
    func backerCard(staker:CrybPostBacker) -> some View{
        let w = self.width - 0
        let view =  HStack(alignment: .center, spacing: 10) {
            Group{
                ImageView(url: staker.Img, width: w * 0.125, height: w * 0.125, contentMode: .fill, clipping: .circleClipping)
                MainText(content: staker.UserName, fontSize: 14, color: .white, fontWeight: .semibold)
            }
            Spacer()
            MainText(content: staker.StakedValue.ToDecimals(), fontSize: 15, color: .green, fontWeight: .semibold)
        }
        .blobify(color: .init(BlurView.regularBlur), clipping: .roundCornerMedium)
        .buttonify {
            print("The button was clicked !")
        }
        
        return view
    }
    
    var backers:some View{
        VStack(alignment: .leading, spacing: 10) {
            let more = self.postData.Stakers.count > 5
            let stakers = more ? Array(self.postData.Stakers[0...4]) : self.postData.Stakers
            MainText(content: "Backers", fontSize: 18, color: .white, fontWeight: .semibold)
            ForEach(Array(stakers.enumerated()),id:\.offset) { _staker in
                let staker = _staker.element
                self.backerCard(staker: staker)
            }
            if more{
                TabButton(width: self.width, height: 50, title: "More →", textColor: .white) {
                    print("Clicked on View More!")
                }
            }
        }.frame(width: self.width, alignment: .center)
    }
}

struct CrybPostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            mainBGView
            ScrollView(.vertical, showsIndicators: false) {
                CrybPostDetailView(postData: .test)
            }
        }.ignoresSafeArea()
        
    }
}
