//
//  AutoTimeCardsView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/08/2021.
//

import SwiftUI

struct AutoTimeCardsView: View {
    var data:[Any]
    @StateObject var SP:swipeParams
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    var size:CGSize
    var view: (Any,CGSize) -> AnyView
    init(data:[Any],size:CGSize = .init(width: totalWidth, height: totalHeight * 0.5),view:@escaping (Any,CGSize) -> AnyView){
        self.data = data
        self.view = view
        self.size = size
        self._SP = .init(wrappedValue: .init(0, data.count - 1, 50, type: .Carousel))
    }
    
    var offset:CGFloat{
        return self.SP.swiped > 0 ? -totalWidth : 0
    }
    
    func checkTime(){
//        DispatchQueue.main.async {
            if self.time != 15{
                self.time += 1
            }else{
                self.time = 0
                withAnimation(.linear(duration: 0.35)) {
                    self.SP.swiped  = self.SP.swiped + 1 < self.data.count ? self.SP.swiped + 1 : 0
                }
            }
//        }
    }
    
    var CarouselView:some View{
        ZStack(alignment: .leading) {
            ForEach(Array(self.data.enumerated()), id: \.offset) { _data in
                let data = _data.element
                let idx = _data.offset
                let off = idx > self.SP.swiped ? totalWidth : 0
                let scale:CGFloat = idx < self.SP.swiped ? 0.9 : 1
                if idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1{
                    self.view(data,size)
                        .offset(x: off)
                        .scaleEffect(scale)
                }
            }
        }
//        .animation(.linear(duration: 0.35))
        .onReceive(self.timer) { _ in self.checkTime()}
        
    }
    

    var body: some View {
        self.CarouselView
    }
}
