//
//  RecentNews.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNews: View {
    @StateObject var news:FeedAPI
    var currency:String
    var containerSize:CGSize
    let font_color:Color = .black
    var ext_h:Bool
    @State var idx:Int = 0
    init(currency:String,size:CGSize = .init(width: totalWidth - 20, height: totalHeight * 1.1),ext_h:Bool = false){
        self._news = .init(wrappedValue: .init(currency: [currency],sources:["news"],type:.Influential))
        self.currency = currency
        self.containerSize = size
        self.ext_h = ext_h
    }
    
    func onAppear(){
        if self.news.FeedData.isEmpty{
            self.news.getAssetInfo()
        }
    }
    
    var newsData:[AssetNewsData]{
        return self.news.FeedData.count > 5 ? Array(self.news.FeedData[0..<3]) : self.news.FeedData
    }
    
    
    var mainBody:some View{
        GeometryReader{g in
            
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(self.newsData.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    let isSelected = self.idx == idx
                    let cardSize = CGSize(width: w, height: h * (isSelected ? 0.5 : 0.25) - 5)
                    
                    RecentNewsCard(data: data, size: cardSize, selected: isSelected)
                        .onTapGesture{
                            self.idx = idx
                        }
                }
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        .animation(.easeInOut)
        .onAppear(perform: self.onAppear)
    }
    var body: some View {
        if self.ext_h{
            self.mainBody
        }else{
            self.mainBody
                .frame(width: containerSize.width, height: containerSize.height, alignment: .center)
        }
        
        
    
    
    }
}

