//
//  NewsStandCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 14/10/2021.
//

import SwiftUI

struct NewsStandCard: View {
    @EnvironmentObject var context:ContextData
//    var news:AssetNewsData
    var news:CrybseNews
    var size:CGSize
    
    init(news:CrybseNews,size:CGSize = .init(width: totalWidth - 20, height: 250)){
        self.news = news
        self.size = size
    }

    
    @ViewBuilder var mainText:some View{
        MainTextSubHeading(heading: self.news.source_name ?? "Publisher", subHeading: self.news.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .top, spacing: 10) {
            self.mainText
                .frame(height: h, alignment: .topLeading)
            Spacer()
            ImageView(url: self.news.ImageURL, width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            
            
        }
    }
    
    func footer(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .center, spacing: 5) {
            MainText(content: self.news.DateText, fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
            Spacer()
            SystemButton(b_name: "circle.grid.2x2", color: .white) {
                print("Hi")
            }
        }
    }
    
    var mainBody:some View{
        //        GeometryReader{g in
        let w = size.width - 30
        let h = size.height - 30
        
        let main_h = h - 50
        
        return VStack(alignment: .leading, spacing: 10){
            self.mainBody(w: w, h: main_h)
            RoundedRectangle(cornerRadius: 15)
                .frame(width: w, height: 1, alignment: .center)
                .foregroundColor(.gray)
                .padding(.top,5)
            self.footer(w: w, h: 50)
        }.padding(15)
            .frame(width: self.size.width, height: self.size.height, alignment: .center)
            .background(BlurView(style: .systemThickMaterialDark))
            .clipContent(clipping: .roundCornerMedium)
    }

    var body: some View {
        self.mainBody
            .buttonify {
                if self.context.selectedNews?.news_url != self.news.news_url{
                    self.context.selectedNews = self.news
                }
            }

        
    }
}

struct NewsStand:View{
    var width:CGFloat
    @StateObject var newsAPI:CrybseNewsAPI
    @State var showMoreView:Bool = false
    init(currency:[String] = ["BTC"],width:CGFloat = totalWidth){
        self._newsAPI = .init(wrappedValue: .init(tickers: currency.reduce("", {$0 == "" ? $1 : $0 + "," + $1})))
        self.width = width
    }
    
    func onAppear(){
        if self.newsAPI.newsList == nil{
            self.newsAPI.getNews()
        }
    }
    
    var NewsList:CrybseNewsList{
        return self.newsAPI.newsList ?? []
    }
    
    var body: some View{
        ZStack(alignment:.top){
            if self.NewsList.isEmpty{
                ProgressView()
            }else{
                VStack(alignment: .center, spacing: 10) {
                    ForEach(Array(self.NewsList.enumerated()),id:\.offset) { _data in
                        NewsStandCard(news: _data.element,size: .init(width: width, height: 225))
                    }
                    TabButton(width: width, title: "Load More", action: {
                        withAnimation(.easeInOut) {
                            self.showMoreView = true
                        }
                    }).padding(.top,10)
                }
            }
        }.onAppear(perform: self.onAppear)
    }
    
}

struct NewsStandCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false){
            Container(heading: "News", width: totalWidth, ignoreSides: false) { w in
                NewsStand(width:w)
            }.padding(.top,20)
            
        }
        .frame(width: totalWidth,height: totalHeight, alignment: .center)
        .background(Color.mainBGColor.edgesIgnoringSafeArea(.all))
            
    }
}
