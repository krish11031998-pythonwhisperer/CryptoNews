//
//  NewsDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/04/2022.
//

import SwiftUI

struct NewsDetailView: View {
    var news:CrybseNews
    var width:CGFloat
    
    init(news:CrybseNews,width:CGFloat){
        self.news = news
        self.width = width
    }
    
    @ViewBuilder func newsImageView(w:CGFloat) -> some View{
        if let imgUrl = self.news.image_url{
            ImageView(url: imgUrl, width: w, contentMode: .fill, alignment: .center, autoHeight: true, isPost: false, clipping: .roundClipping)
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder func newsInfoView(w:CGFloat) -> some View{
        if let title = self.news.title{
            MainText(content: title, fontSize: 22.5, color: .white, fontWeight: .medium)
        }
        HStack(alignment: .center, spacing: 10) {
            MainTextSubHeading(heading: self.news.SourceName, subHeading: self.news.DateText, headingSize: 17, subHeadingSize: 13, headColor: .white, subHeadColor: .white.opacity(0.5), orientation: .vertical, headingWeight: .medium, bodyWeight: .medium, spacing: 10, alignment: .topLeading)
            Spacer()
            if let sentiment = self.news.sentiment{
                let color = sentiment == "Positive" ? Color.green : sentiment == "Negative" ? Color.red : Color.gray
                MainText(content: sentiment, fontSize: 12, color: color, fontWeight: .medium, padding: 10)
                    .basicCard(background: BlurView.thinLightBlur.background(color).anyViewWrapper())
                    .borderCard(color: color.opacity(0.25), clipping: .roundClipping)
            }
        }
        
    }
    
    @ViewBuilder func newsDescriptionView(w:CGFloat) -> some View{
        if let description = self.news.text{
            MainText(content: description, fontSize: 20, color: .white, fontWeight: .medium)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical,15)
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    func onClose(){
        print("(DEBUG) onClose")
    }
    
    var body: some View {
        Container(width: self.width,orientation: .vertical, aligment: .topLeading, spacing: 10) { w in
            self.newsInfoView(w: w)
            self.newsImageView(w: w)
            self.newsDescriptionView(w: w)
        }
    }
}

//struct NewsDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsDetailView()
//    }
//}
