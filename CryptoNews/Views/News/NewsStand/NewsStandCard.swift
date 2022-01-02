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
//    init(news:AssetNewsData,size:CGSize = .init(width: totalWidth - 20, height: 250)){
//        self.news = news
//        self.size = size
//    }
    init(news:Any,size:CGSize = .init(width: totalWidth - 20, height: 250)){
        self.news = news
        self.size = size
    }

    
    @ViewBuilder var mainText:some View{
        if let data = self.news as? AssetNewsData{
            MainSubHeading(heading: data.publisher ?? "Publisher", subHeading: data.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
        }else if let data = self.news as? CryptoNews{
            MainSubHeading(heading: data.source_info?.name ?? "Publisher", subHeading: data.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
                .lineLimit(2)
        }
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .top, spacing: 10) {
            self.mainText
                .frame(height: h - 20, alignment: .topLeading)
            Spacer()
            if let data = self.news as? AssetNewsData{
                ImageView(url: data.image, width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }else if let data = self.news as? CryptoNews{
                ImageView(url: data.imageurl,width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }else{
                ImageView(width: w * 0.35, height: h, contentMode: .fill, alignment: .center,clipping: .squareClipping)
            }
            
        }
    }
    
    func footer(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .center, spacing: 5) {
            if let data = self.news as? AssetNewsData{
                MainText(content: data.date.stringDate(), fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
            }else if let data = self.news as? CryptoNews{
                MainText(content: "\(data.published_on)",fontSize: 10, color: .white, fontWeight: .regular, style: .monospaced)
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
            withAnimation(.easeInOut) {
                if let news = self.news as? AssetNewsData{
                    self.context.selectedNews = news
                }
            }
        } label: {
            self.mainBody
        }.springButton()

        
    }
}

struct NewsStand:View{
    var width:CGFloat
    @StateObject var MAPI:FeedAPI
    @State var showMoreView:Bool = false
    init(currency:[String] = ["BTC"],width:CGFloat = totalWidth){
        self._MAPI = .init(wrappedValue: .init(currency: currency, sources: ["news"], type: .Chronological, limit: 5, page: 0))
        self.width = width
    }
    
    func onAppear(){
        if self.MAPI.FeedData.isEmpty{
            self.MAPI.getAssetInfo()
        }
    }
    
    
    var body: some View{
//        Container(heading: "News", width: width) { w in
                ZStack(alignment:.top){
                    if self.MAPI.FeedData.isEmpty{
                        ProgressView()
                    }else{
                        VStack(alignment: .center, spacing: 10) {
                            ForEach(self.MAPI.FeedData) { data in
                                NewsStandCard(news: data,size: .init(width: width, height: 225))
                            }
                            TabButton(width: width, title: "Load More", action: {
                                withAnimation(.easeInOut) {
                                    self.showMoreView = true
                                }
                            }).padding(.top,10)
                        }
                    }
                }.onAppear(perform: self.onAppear)
//        }
    }
    
}

struct NewsStandCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false){
            Container(heading: "News", width: totalWidth, ignoreSides: false) { w in
                NewsStand(width:w)
            }.padding(.top,20)
            
        }
//        .padding(.vertical,50)
//        .padding(.top,50)
        .frame(width: totalWidth,height: totalHeight, alignment: .center)
        .background(Color.mainBGColor.edgesIgnoringSafeArea(.all))
            
    }
}
