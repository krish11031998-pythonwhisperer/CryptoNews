//
//  CardSlidingView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/08/2021.
//

import SwiftUI

struct CardSlidingView: View {
    var cardSize:CGSize
    var views:Array<AnyView>
    @StateObject var SP:swipeParams
    var leading:Bool
    init(cardSize:CGSize = CardSize.slender,views:Array<AnyView>,leading:Bool = true){
        self.cardSize = cardSize
        self.views = views
        self.leading = leading
        self._SP = .init(wrappedValue: .init(0, views.count - 1, 100, type: .Carousel))
    }
    
    var scrolledOffset:CGFloat{
        let off =  CGFloat(self.SP.swiped >= 2 ? 2 : self.SP.swiped < 0 ? 0 : self.SP.swiped) * -(self.cardSize.width) - 10
        return off
    }
    
    
    func zoomInOut(view:AnyView) -> some View{
        GeometryReader{g in
            let midX = g.frame(in: .global).midX
            let diff = abs(midX - (totalWidth * 0.5))/totalWidth
            let diff_percent = (diff > 0.25 ? 1 : diff/0.25)
            let scale = 1 - 0.075 * diff_percent
            
            view.scaleEffect(scale)
            
        }.frame(width: cardSize.width, height: cardSize.height, alignment: .center)
    }
    
    var halfCardWidth:CGFloat{
        return (totalWidth - self.cardSize.width) * 0.5
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 15){
                ForEach(Array(self.views.enumerated()),id: \.offset){ _view in
                    let idx = _view.offset
                    let view = _view.element
                    zoomInOut(view: view)
                        .padding(.leading,idx == 0 ? 15 : 0)
//                        .padding(.trailing, idx == self.views.count - 1 ? 15 : 0)
                }
            }
            .padding(.leading, self.leading ? halfCardWidth : 0)
            .padding(.trailing,halfCardWidth)
        }
        .frame(width:totalWidth,height: cardSize.height,alignment: .leading)
    }
}

//struct CardSlidingView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardSlidingView()
//    }
//}
