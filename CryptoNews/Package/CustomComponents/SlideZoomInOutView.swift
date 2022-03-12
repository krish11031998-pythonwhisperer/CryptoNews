//
//  FacnyHScroll.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/08/2021.
//

import SwiftUI
import Combine

public struct SlideZoomInOutView<T:View>: View {
    @State var time:Int = 0
    @StateObject var SP:swipeParams
    @State var reset:Bool = false
    
    @ViewBuilder var viewGen:(Any,CGSize) -> T
    var onTap:((Int) -> Void)?
    var data:[Any]
    var timeLimit:Int
    var scrollable:Bool
    var size:CGSize
    var headers:[String]?
    var timer:Publishers.Autoconnect<Timer.TimerPublisher>

    public init(data:[Any],timeLimit:Int = 10,headers:[String]? = nil,size:CGSize,scrollable:Bool = false,onTap:((Int) -> Void)? = nil,@ViewBuilder viewGen: @escaping (Any,CGSize) -> T){
        self.data = data
        self.timeLimit = timeLimit
        self._SP = StateObject(wrappedValue: .init(0, data.count - 1, 50 , type: .Carousel,onTap:onTap))
        self.size = size
        self.headers = headers
        self.timer = Timer.publish(every: TimeInterval(timeLimit),on:.main,in:.common).autoconnect()
        self.scrollable = scrollable
        self.viewGen = viewGen
        self.onTap = onTap
    }
    
    func scaleEff(midX:CGFloat) -> CGFloat{
        let thres:CGFloat = totalWidth * 0.25
        let tar = totalWidth * 0.15
        var perc = (midX - tar)/(thres - tar)
        perc = midX > totalWidth ? (perc > 1 ? 1 : perc < 0 ? 0 : perc) : 1 - (perc > 1 ? 1 : perc < 0 ? 0 : perc)
        let scale = midX < thres || midX > (1 - thres) ? 1 - 0.2 * CGFloat(perc) : 1
        return scale
    }

    @ViewBuilder func Card(data:Any,size _size:CGSize) -> some View{
        let view = GeometryReader{g in
            let size = g.frame(in: .local).size
            let midX = g.frame(in: .global).midX
            
            
            self.viewGen(data,size)
                .scaleEffect(scaleEff(midX: midX))
                .animation(.spring())
        }
            .padding(0)
        .frame(width: _size.width, height: _size.height, alignment: .center)
        
        let dragGesture = DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:))
        if self.scrollable{
            if let onTap = self.onTap {
                view
                    .gesture(dragGesture)
                    .buttonify {
                        self.onTap?(self.SP.swiped)
                    }
            }else{
                view
                    .gesture(dragGesture)
            }
        }else{
            view
                
        }
    }
    
    var offset:CGFloat{
        return -CGFloat(self.reset || self.SP.swiped <= 1 ? self.SP.swiped : 1) * size.width
    }
    
    func onReceiveTimer(){
        if self.time == self.timeLimit{
            setWithAnimation {
                let newSwipe = self.SP.swiped + 1 <= self.data.count - 1 ? self.SP.swiped + 1 : 0
                if newSwipe == 0 &&  !self.reset{
                    self.reset.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    withAnimation(.easeInOut){
                        self.SP.swiped = newSwipe
                    }
                }
                if self.SP.extraOffset != .zero{
                    self.SP.extraOffset = .zero
                }
            }
        }else{
            self.time += 1
        }
    }
    
    func resetTimer(_ idx:Int){
        self.time = 0
        if idx == 0 && self.reset{
            self.reset.toggle()
        }
    }
    
    func headerView(h:CGFloat) -> some View{
        LazyHStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.headers!.enumerated()),id:\.offset) { _cur in
                let cur = _cur.element
                let idx = _cur.offset
                
                Button {
                    withAnimation(.easeInOut) {
                        self.SP.swiped = idx
                    }
                } label: {
                    TimerBlobs(text: cur, h: h, time: self.$time, targetTime: timeLimit, active: self.SP.swiped == idx)
                }
            }
        }.frame(width:size.width,height:h)
    }
    
    
    var mainBodywithHeaders:some View{
        LazyVStack(alignment: .leading, spacing: 10) {
            let timeBlob_h = self.size.height * 0.1 - 5
            let mainView_h = self.size.height * ( self.headers == nil ? 1 : 0.9) - 5


            if let _ = self.headers{
                self.headerView(h:timeBlob_h)
            }
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(self.data.enumerated()), id:\.offset) { _data in
                    let data = _data.element
                    
                    self.Card(data: data, size: CGSize(width: size.width, height: mainView_h))
                }
            }
            
            Spacer()
        }
    }
    
    var mainBodywithoutHeaders:some View{
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.data.enumerated()), id:\.offset) { _data in
                let data = _data.element
                let idx = _data.offset
                
                if (idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1) || self.reset{
                    self.Card(data: data, size: CGSize(width: size.width, height: self.size.height))
                }
                
            }
        }
    }
    
    @ViewBuilder var mainBody:some View{
        if self.headers != nil{
            self.mainBodywithHeaders
        }else{
            self.mainBodywithoutHeaders
        }
    }
    
    public var body: some View {
        self.mainBody
            .frame(width:size.width,height: size.height, alignment: .leading)
            .offset(x: self.SP.extraOffset + self.offset)
            .onReceive(self.timer, perform: { _ in
                withAnimation(.easeInOut) {
                    self.onReceiveTimer()
                }
            })
            .onChange(of: self.SP.swiped, perform: self.resetTimer)
        
    }
}


//struct FancyScrollViewPreview:PreviewProvider{
//
//    static var previews: some View{
//        FancyHScroll(data: Array(0...10), size: CardSize.slender,scrollable: true) { idx in
//            Container(heading: "\(idx)", width: CardSize.slender.width, ignoreSides: false, horizontalPadding: 10, verticalPadding: 10) { _ in
//                MainText(content: "\(idx)", fontSize: 15)
//            }.basicCard(size: CardSize.slender)
//        }
//    }
//}
