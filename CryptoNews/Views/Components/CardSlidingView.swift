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
    init(cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5),views:Array<AnyView>,leading:Bool = true){
        self.cardSize = cardSize
        self.views = views
        self.leading = leading
        self._SP = .init(wrappedValue: .init(0, views.count - 1, 100, type: .Carousel))
    }
    
    var scrolledOffset:CGFloat{
        let off =  CGFloat(self.SP.swiped >= 2 ? 2 : self.SP.swiped < 0 ? 0 : self.SP.swiped) * -(self.cardSize.width) - 10
        return off
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            Spacer().frame(width: self.leading ? (totalWidth - self.cardSize.width) * 0.5 : 0)
            ForEach(Array(self.views.enumerated()),id: \.offset){ _view in
                let view = _view.element
                let idx = _view.offset
                let selected = idx == self.SP.swiped
                let scale:CGFloat = selected ? 1.05 : 0.9
                if idx >= self.SP.swiped - 2 && idx <= self.SP.swiped + 2{
                    view
                        .scaleEffect(scale)
                        .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
                }
            }
            Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
        }
        .edgesIgnoringSafeArea(.horizontal)
        .frame(width:totalWidth,height: cardSize.height * 1.01,alignment: .leading)
        .padding(.leading,10)
        .offset(x: self.scrolledOffset)
        .offset(x: self.SP.extraOffset)
        .animation(.easeInOut(duration: 0.65))
    }
}

//struct CardSlidingView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardSlidingView()
//    }
//}
