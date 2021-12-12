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
    @State var chartIndicator:Int = -1
    @EnvironmentObject var context:ContextData
    
    init(postData:CrybPostData){
        self.postData = postData
    }
    
    var mainBodyGen:some View{
        return LazyVStack(alignment: .leading, spacing: 10) {
            self.postBody.frame(maxHeight: totalHeight * 0.65, alignment: .center)
            self.socialEngagementView
            self.cryptoSection
            self.cryptoScale
            self.ratingsView
            self.backers
        }.frame(width: self.width, alignment: .center)
    }
    
    func loadView(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return ProgressView()
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
            Container(width: totalWidth,ignoreSides: false, horizontalPadding: 15,verticalPadding: 50,onClose: self.onClose) { w in
                if self.width == .zero{
                    self.loadView(w: w)
                }else{
                    self.postBody.frame(maxHeight: totalHeight * 0.65, alignment: .center)
                    self.socialEngagementView
                    self.cryptoSection
                    self.cryptoScale
                    self.ratingsView
                    self.backers
//                    self.mainBodyGen
                }
            }.padding(.bottom,150)
                .frame(width: totalWidth, alignment: .center)
        }
    }
}

extension CrybPostDetailView{
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
    func likeButtonHandler(){
        print("Clicked on Like")
    }
    
    func commentButtonHandler(){
        print("Clicked on Comment")
    }
    
    func shareButtonHandler(){
        print("Clicked on Share")
    }
    
    var socialEngagementView:some View{
        let buttons:[(String,String,() -> Void)] = [("heart","Like",self.likeButtonHandler),("message","Comment",self.commentButtonHandler),("square.and.arrow.up","Share",self.shareButtonHandler)]
        return HStack(alignment: .center, spacing: 10) {
            ForEach(buttons, id:\.0) { button in
                SystemButton(b_name: button.0, b_content: button.1, color: .white,haveBG: false, bgcolor: .white, alignment: .horizontal,borderedBG: true,action: button.2)
            }
        }.frame(width: width,alignment: .leading)
//        .background(Color.yellow)
    }
    
    var postBody:some View{
        Container(width: self.width, ignoreSides: false) { w in
            self.header(w: w)
            self.mainBody(w: w)
            ImageView(url: self.postData.PostImage, width: w, height: 200, contentMode: .fill, alignment: .center, autoHeight: true,clipping: .roundCornerMedium)
        }
        .padding(.bottom,25)
        .frame(width: self.width, alignment: .topLeading)
        .frame(maxHeight: totalHeight * 0.75)
        .background(mainLightBGView)
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
            .padding(.leading,10)
            .frame(width: w, alignment: .leading)
    }
    
    
    var cryptoSection:some View{
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
        let cryb_prediction = self.crybPredictedData[self.indicator]
        
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: "Crybot's Prediction", fontSize: 18, color: .white, fontWeight: .semibold).padding(.bottom,10)
            MainSubHeading(heading: "Value", subHeading: cryb_prediction.ToMoney(), headingSize: 13, subHeadingSize: 15, headColor: .gray, subHeadColor: .white, alignment: .leading)
                .frame(width: self.width, alignment: .leading)
            
            CurveChart(data: self.postData.PricePrediction.GraphData, choosen: self.$chartIndicator, interactions: true, size: size, bg: .clear)
            
            HStack(alignment: .center, spacing: 10) {
                MainText(content: "Crybot's Market Prediction", fontSize: 15, color: .white, fontWeight: .medium)
                Spacer()
                MainText(content: "Bear 🐻", fontSize: 20, color: .red, fontWeight: .semibold)
            }.blobify(color: .init(BlurView.regularBlur), clipping: .roundCornerMedium)
            .padding(.vertical,10)
        }.padding(.vertical,20)
    }
    
    var userPredictionMarket:some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "User's Market Prediction", fontSize: 15, color: .white, fontWeight: .medium)
            Spacer()
            MainText(content: "Bull 🐂", fontSize: 20, color: .green, fontWeight: .semibold)
        }.blobify(color: .init(BlurView.regularBlur), clipping: .roundCornerMedium)
            .padding(.vertical,10)
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
            view.padding(.top,15)
            HStack(alignment: .center, spacing: 10) {
                MainSubHeading(heading: "O : Open Market Price", subHeading: self.postData.PricePrediction.Price.ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
                MainSubHeading(heading: "C : Close Market Price", subHeading: (self.postData.PricePrediction.Price * 0.98).ToMoney(), headingSize: 9, subHeadingSize: 12, headColor: .white, subHeadColor: .white, alignment: .leading)
                    .blobify(color: AnyView(BlurView.thinDarkBlur),clipping: .roundCornerMedium)
            }.frame(width: w, alignment: .center)
            self.userPredictionMarket
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
        LazyVStack(alignment: .leading, spacing: 10) {
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
