//
//  CryptoPostCardView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CryptoPostCardView: View {
    var width:CGFloat
    var postData:CrybPostData
    
    init(postData:CrybPostData,width:CGFloat = totalWidth - 30){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        Container(width: self.width, ignoreSides: false) { w in
            self.header(w: w)
            self.mainBody(w: w)
            ImageView(url: self.postData.ImageURL, width: w, height: 200, contentMode: .fill, alignment: .center, autoHeight: true,clipping: .roundCornerMedium)
        }
        .padding(.bottom,25)
        .frame(width: self.width, alignment: .topLeading)
        .frame(maxHeight: totalHeight * 0.75)
        .background(mainLightBGView)
        .clipContent(clipping: .roundClipping)
    }
}

extension CryptoPostCardView{    
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
}
