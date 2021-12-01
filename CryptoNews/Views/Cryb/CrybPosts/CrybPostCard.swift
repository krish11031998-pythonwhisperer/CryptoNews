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
    
   
    
    func view(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width == .zero{
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
        Container(width: totalWidth - 20, ignoreSides: false) { w in
            self.view(w: w)
        }.background(Color.white.opacity(0.5).overlay(BlurView(style: .regular))).clipContent(clipping: .roundClipping)
    }
}

extension CrybPostCard{
    
    var img_width:CGFloat{
        return self.width * 0.15
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
            CurrencySymbolView(currency: self.postCardData.Coin, size: .medium, width: self.img_width)
            MainText(content: self.postCardData.Coin, fontSize: 15, color: .black, fontWeight: .regular)
            Spacer()
            self.cryptoScale
        }.frame(width: self.width, alignment: .leading)
    
    }
    
    var cryptoScale:some View{
        let w = self.width * 0.4
        return ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.mainBGColor)
                    .frame(width: w, height: 5, alignment: .center)
                HStack(alignment: .center, spacing: 10) {
                    MainText(content: self.postCardData.PricePrediction.Low.ToMoney(), fontSize: 10, color: .black,fontWeight: .medium)
                    Spacer()
                    MainText(content: self.postCardData.PricePrediction.High.ToMoney(), fontSize: 10, color: .black,fontWeight: .medium)
                }
            }.frame(width: w, alignment: .center)
            VStack(alignment: .center, spacing: 10) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                MainText(content: self.postCardData.PricePrediction.Price.ToMoney(), fontSize: 17.5, color: .black, fontWeight: .bold)
            }.frame(width: w, alignment: .leading)
//            .offset(x: CGFloat(self.postCardData.PricePrediction.NormalizedPricePercent) * w)
        }
        
    }
    
    var footer:some View{
        VStack(alignment: .leading, spacing: 10) {
            self.cryptoSection
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
