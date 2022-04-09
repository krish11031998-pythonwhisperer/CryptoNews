//
//  RecentNews.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNews: View {
    @StateObject var news:CrybseNewsAPI
    var currency:String
    var containerSize:CGSize
    let font_color:Color = .black
    var ext_h:Bool
    @State var idx:Int = 0
    init(currency:String,size:CGSize = .init(width: totalWidth - 20, height: totalHeight * 1.1),ext_h:Bool = false){
        self._news = .init(wrappedValue: .init(tickers: currency))
        self.currency = currency
        self.containerSize = size
        self.ext_h = ext_h
    }
    
    func onAppear(){
        if self.news.newsList == nil{
            self.news.getNews()
        }
    }

    
    var newsData:CrybseNewsList{
        guard let safeNewsList = self.news.newsList else {return []}
        return safeNewsList.count > 5 ? Array(safeNewsList[0..<3]) : safeNewsList
    }
    
    
    var mainBody:some View{
//        GeometryReader{g in
            
        let w = containerSize.width - 30
        let h = containerSize.height - 30
        
        return VStack(alignment: .leading, spacing: 10) {
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
            //            }
            
        }
        .animation(.easeInOut)
        .padding(15)
        .frame(width: containerSize.width, height: containerSize.height, alignment: .center)
        .background(BlurView(style: .dark))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
//        .animation(.easeInOut)
        .onAppear(perform: self.onAppear)
    }
    var body: some View {
        self.mainBody
    }
}

