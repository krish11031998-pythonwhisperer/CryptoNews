//
//  NewsStandCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 14/10/2021.
//

import SwiftUI

struct NewsStandCard: View {
    @EnvironmentObject var context:ContextData
    var news:AssetNewsData
    var size:CGSize
    init(news:AssetNewsData,size:CGSize = .init(width: totalWidth - 20, height: 125)){
        self.news = news
        self.size = size
    }
    
    var mainBody:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            HStack(alignment: .top, spacing: 10) {
                ImageView(url: self.news.image, width: w * 0.25, height: h, contentMode: .fill, alignment: .center,clipping: .roundClipping)
                MainSubHeading(heading: self.news.publisher ?? "Publisher", subHeading: self.news.title ?? "Title", headingSize: 10, subHeadingSize: 15,headingFont: .monospaced)
                
                Spacer()
            }
        }.padding(10)
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
        .background(BlurView(style: .systemThickMaterialDark))
        .clipContent(clipping: .roundClipping)
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                self.context.selectedNews = news
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
                                NewsStandCard(news: data,size: .init(width: width, height: 150))
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
            NewsStand()
        }
        .padding(.vertical,50)
        .padding(.top,50)
        .frame(width: totalWidth,height: totalHeight, alignment: .center)
        .background(Color.mainBGColor.edgesIgnoringSafeArea(.all))
            
    }
}