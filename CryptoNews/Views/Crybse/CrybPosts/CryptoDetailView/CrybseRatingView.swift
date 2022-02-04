//
//  CrybseRatingView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CrybseRatingView: View {
    var width:CGFloat
    var postData:CrybPostData
    
    init(postData:CrybPostData,width:CGFloat = totalWidth - 30){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        Container(heading: "Ratings", headingDivider: false,headingSize: 18, width: self.width, ignoreSides: true,horizontalPadding: 0) { _ in
            let w_el = self.width * 0.5 - 5
            LazyVGrid(columns: [.init(.adaptive(minimum: w_el, maximum: w_el), alignment: .leading)], alignment: .center, spacing: 10) {
                self.RatingsMeter(header: "Cryb. Rating", percent: 60,w: w_el)
                self.RatingsMeter(header: "Audience Rating", percent: 75,w: w_el)
            }.frame(width: self.width, alignment: .leading)
        }
    }
}

extension CrybseRatingView{
    func RatingsMeter(header:String,percent:Float,w:CGFloat) -> some View{
        let subHeading:String = percent > 60 ? "Very Likely" : percent > 40 ? "Likely" : "Unlikely"
        return HStack(alignment: .center, spacing: 10) {
            CircleChart(percent: percent, size: .init(width: w * 0.35, height: w * 0.35))
            MainSubHeading(heading: header, subHeading: subHeading, headingSize: 12, subHeadingSize: 14, headColor: .gray, subHeadColor: .white, alignment: .leading)
        }.padding(.top,20)
    }

}

//struct CrybseRatingView_Previews: PreviewProvider {
//    static var previews: some View {
//        CrybseRatingView()
//    }
//}
