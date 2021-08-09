//
//  RecentNewsCarousel.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNewsCarousel: View {
    var currencies:[String]
    @StateObject var SP:swipeParams
    
    init(currencies:[String] = ["BTC","LTC"]){
        self.currencies = currencies
        self._SP = StateObject(wrappedValue: .init(0, currencies.count - 1, 50, type: .Carousel))
    }
    
    func scaleEff(midX:CGFloat) -> CGFloat{
        let thres:CGFloat = totalWidth * 0.25
        let tar = totalWidth * 0.15
        var perc = (midX - tar)/(thres - tar)
        perc = midX > totalWidth ? (perc > 1 ? 1 : perc < 0 ? 0 : perc) : 1 - (perc > 1 ? 1 : perc < 0 ? 0 : perc)
        let scale = midX < thres || midX > (1 - thres) ? 1 - 0.2 * CGFloat(perc) : 1
        return scale
    }
    
    func newsCard(idx:Int,currency:String,size:CGSize) -> some View{
        return GeometryReader{g in
            let midX = g.frame(in: .global).midX
//            let scale:CGFloat = idx == self.SP.swiped ? 1 : 0.8
            RecentNews(currency: currency,size: size)
                .scaleEffect(scaleEff(midX: midX))
                
            
        }.frame(width: size.width, height: size.height, alignment: .center)
        .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
    }
    
    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * totalWidth
    }
    
    var body: some View {
        
        let w = totalWidth - 20
        let h = totalHeight * 1.1
        HStack(alignment: .center, spacing: 20) {
            ForEach(Array(self.currencies.enumerated()),id:\.offset) { _currency in
                let currency = _currency.element
                let idx = _currency.offset
                let scale:CGFloat = idx == self.SP.swiped ? 1 : 0.8
                if idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1{
//                    RecentNews(currency: currency,size: .init(width: w, height: h))
//                        .scaleEffect(scale)
//                        .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))

                    newsCard(idx:idx,currency: currency, size: .init(width: w, height: h))
                        
                }
            }
        }
        .padding(.leading)
        .frame(width: totalWidth, height: h, alignment: .leading)
        .offset(x: self.SP.extraOffset + self.offset)
        .animation(.easeInOut)
    }
    
}

struct RecentNewsCarousel_Previews: PreviewProvider {
    static var previews: some View {
        RecentNewsCarousel()
    }
}
