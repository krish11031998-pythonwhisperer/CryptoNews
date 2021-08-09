//
//  RecentNews.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNews: View {
    @StateObject var news:NewsAPI
    var currency:String
    var containerSize:CGSize
    @State var idx:Int = 0
    init(currency:String,size:CGSize = .init(width: totalWidth - 20, height: totalHeight * 1.1)){
        self._news = .init(wrappedValue: .init(currency: currency))
        self.currency = currency
        self.containerSize = size
    }
    
    func onAppear(){
        if self.news.newsData.isEmpty{
            self.news.getAssetInfo()
        }
    }
    
    var newsData:[AssetNewsData]{
        return self.news.newsData.count > 5 ? Array(self.news.newsData[0..<5]) : self.news.newsData
    }
    
    var body: some View {
        GeometryReader{g in
            
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment: .leading, spacing: 10) {
                MainText(content: "\(currency) News", fontSize: 25, color: .white, fontWeight: .semibold)
                    .frame(width:w,height: h * 0.05, alignment: .leading)
                ForEach(Array(self.newsData.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    let isSelected = self.idx == idx
                    let cardSize = CGSize(width: w, height: h * (isSelected ? 0.35 : 0.15) - 10)
                    
                    RecentNewsCard(data: data, size: cardSize, selected: isSelected)
                        .onTapGesture{
                            withAnimation(.easeInOut) {
                                self.idx = idx
                            }
                        }
                }
            }
            
        }.padding()
        .frame(width: containerSize.width, height: containerSize.height, alignment: .center)
        .background(Color.black)
        .cornerRadius(20)
        .shadow(color: .white.opacity(0.2), radius: 5, x: 0, y: 0)
        .animation(.easeInOut)
        .onAppear(perform: self.onAppear)
    
    
    }
}

//struct RecentNews_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentNews()
//    }
//}
