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
    var news:Any
    var size:CGSize
    
    init(news:Any,size:CGSize = .init(width: totalWidth - 20, height: 250)){
        self.news = news
        self.size = size
    }

    
    @ViewBuilder var mainText:some View{
        if let data = self.news as? CrybseNews{
            MainSubHeading(heading: data.source_name ?? "Publisher", subHeading: data.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
        }else if let data = self.news as? CryptoNews{
            MainSubHeading(heading: data.source_info?.name ?? "Publisher", subHeading: data.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
                .lineLimit(2)
        }
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .top, spacing: 10) {
            self.mainText
                .frame(height: h, alignment: .topLeading)
            Spacer()
            if let data = self.news as? CrybseNews{
                ImageView(url: data.ImageURL, width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }else if let data = self.news as? CryptoNews{
                ImageView(url: data.imageurl,width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }else{
                ImageView(width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }
            
        }
    }
    
    func footer(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .center, spacing: 5) {
            if let data = self.news as? CrybseNews{
                MainText(content: data.Date, fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
            }else if let data = self.news as? CryptoNews,let epochTime = data.published_on, let time = Date(timeIntervalSince1970: Double(epochTime)){
                MainText(content: "\(time.stringDate())",fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
            }
            
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
        Button {
            if let news = self.news as? CrybseNews,let urlStr = news.news_url, let url = URL(string: urlStr){
                self.context.selectedLink = url
            }else if let cryptoNews = self.news as? CryptoNews,let urlStr = cryptoNews.url, let url = URL(string: urlStr){
                self.context.selectedLink = url
            }
        } label: {
            self.mainBody
        }.springButton()

        
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
