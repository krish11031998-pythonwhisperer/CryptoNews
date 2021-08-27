//
//  LatestRedditView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/08/2021.
//

import SwiftUI

struct LatestRedditView: View {
    @StateObject var RedditAPI:FeedAPI
    let font_color:Color = .black
    init(currency:String = "all"){
        self._RedditAPI = .init(wrappedValue: .init(currency: currency == "all" ? ["BTC","LTC","DOGE"] : [currency],sources:["reddit"], type: .Chronological,limit: 50))
    }
    
    func onAppear(){
        if self.RedditAPI.FeedData.isEmpty{
            self.RedditAPI.getAssetInfo()
        }
    }
//
//    func redditView(data:Any,size:CGSize) -> AnyView{
//        let h = size.height == .infinity ? 100 : size.height
//        let view = AnyView(Color.black.opacity(0.5).frame(width: size.width, height: h, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10)))
//        guard let data = data as? AssetNewsData else {return view}
//        return AnyView(PostCard(cardType: .Reddit, data: data, size: size,const_size: true))
//    }
    
    var ImageRedditData:[AssetNewsData]{
        return self.RedditAPI.FeedData.filter({$0.link != nil})
    }
    
    func singleCol(data:[AssetNewsData],width w:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 10) {
            ForEach(Array(data.enumerated()),id: \.offset) { _data in
                let news = _data.element
                ImageView(url: news.link, heading: news.title, width: w, contentMode: .fill, alignment: .center, autoHeight: true, headingSize: 13)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }.aspectRatio(contentMode: .fill)
        
    }
    
    func variableImageHeightRow(data:[AssetNewsData],size:CGSize) -> some View{
        let enum_data = Array(data.enumerated())
        return HStack(alignment: .top, spacing: 10){
            self.singleCol(data: enum_data.compactMap({$0.offset%2 == 1 ? $0.element : nil}), width: size.width * 0.5 - 5)
            self.singleCol(data: enum_data.compactMap({$0.offset%2 == 0 ? $0.element : nil}), width: size.width * 0.5 - 5)
        }.frame(width: size.width)
        .aspectRatio(contentMode: .fill)
    }
    
    var TopRedditPosts:some View{
        let paddingFactor:CGFloat = 15.0
        let w = totalWidth - (2 * paddingFactor)
        //        let small_card_w = w * 0.475
        return VStack(alignment: .leading, spacing: 10){
            if let first = self.ImageRedditData.first{
                ImageView(url: first.link, heading: first.title, width: w, contentMode: .fill, alignment: .center,autoHeight: true, isPost: true,headingSize: 13)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            variableImageHeightRow(data: Array(self.ImageRedditData[1...4]), size: .init(width: w, height: 100))
        }.aspectRatio(contentMode: .fill)
        //        }
    }
    
    var body: some View {
        Container(heading: "Trending Reddit") { w in
            return AnyView(
                ZStack{
                    if !self.RedditAPI.FeedData.isEmpty{
                        self.TopRedditPosts
                    }else{
                        ProgressView()
                    }
                }
                
                
            )
        }.onAppear(perform: self.onAppear)
    }
}

struct LatestRedditView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            LatestRedditView()
        }
    }
}
