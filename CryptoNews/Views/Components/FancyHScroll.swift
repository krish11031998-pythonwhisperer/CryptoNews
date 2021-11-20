//
//  FacnyHScroll.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/08/2021.
//

import SwiftUI

struct FancyHScroll<T:View>: View {
    @EnvironmentObject var context:ContextData
    @State var time:Int = 0
    @StateObject var SP:swipeParams
    
    @ViewBuilder var viewGen:(Any) -> T
    var onTap:((Int) -> Void)?
    var data:[Any]
    var timeLimit:Int
    var scrollable:Bool
    var size:CGSize
    var headers:[String]?
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(data:[Any],timeLimit:Int = 10,headers:[String]? = nil,size:CGSize,scrollable:Bool = false,onTap:((Int) -> Void)? = nil,@ViewBuilder viewGen: @escaping (Any) -> T){
        self.data = data
        self.timeLimit = timeLimit
        self._SP = StateObject(wrappedValue: .init(0, data.count - 1, 50 , type: .Carousel,onTap:onTap))
        self.size = size
        self.headers = headers
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

    @ViewBuilder func Card(data:Any,size:CGSize) -> some View{
        let view = GeometryReader{g in
            let size = g.frame(in: .local)
            let midX = g.frame(in: .global).midX
            
            self.viewGen(data)
                .frame(width: size.width, height: size.height, alignment: .center)
                .scaleEffect(scaleEff(midX: midX))
                .animation(.easeInOut)

        }.padding(.horizontal,15)
            .frame(width: totalWidth, height: size.height, alignment: .center)
        
        let dragGesture = DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:))
        if self.scrollable{
            view
                .gesture(dragGesture)
                .buttonify {
                    self.onTap?(self.SP.swiped)
                }
        }else{
            view
                .gesture(dragGesture)
        }
    }
    
    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * totalWidth
    }
    
    func onReceiveTimer(){
        if self.time == self.timeLimit{
            self.SP.swiped = self.SP.swiped + 1 <= self.data.count - 1 ? self.SP.swiped + 1 : 0
        }else{
            self.time += 1
        }
    }
    
    func resetTimer(_ idx:Int){
        self.time = 0
    }
    
    func headerView(h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
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
                self.Card(data: data, size: CGSize(width: size.width, height: self.size.height))
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
    
    var body: some View {
        self.mainBody
        .frame(width:totalWidth,height: size.height, alignment: .leading)
        .offset(x: self.SP.extraOffset + self.offset)
        .onReceive(self.timer, perform: { _ in
            withAnimation(.easeInOut) {
                self.onReceiveTimer()
            }
        })
        .onChange(of: self.SP.swiped, perform: self.resetTimer)
//        .animation(.easeInOut)
       
    }
}
