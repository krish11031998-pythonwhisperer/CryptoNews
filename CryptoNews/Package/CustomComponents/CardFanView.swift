//
//  CardFanView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/02/2022.
//

import SwiftUI

public enum CardFanSwipe:String {
    case next = "next"
    case prev = "prev"
    case none = "none"
}


public struct FanSwipedPreferenceKey:PreferenceKey{
    public static var defaultValue: String = CardFanSwipe.none.rawValue
    
    public static func reduce(value: inout String, nextValue: () -> String){
        value = nextValue()
    }
}


public class FanSwipedParams:ObservableObject{
    @Published public var swiped:Int = .zero
    @Published public var offset:CGFloat = .zero
    @Published public var offsets:[CGFloat]
    @Published public var refresh:Bool = false
    public var total:Int
    
    public init(totalCards:Int){
        self.total = totalCards
        self._offsets = .init(wrappedValue: .init(repeating: 0.0, count: totalCards))
    }
    
    public func onChanged(ges:DragGesture.Value){
        let width = ges.translation.width
        if self.swiped < self.total - 1{
            setWithAnimation {
                self.offset = width
            }
        }
    }
    
    public func onEnded(ges:DragGesture.Value){
        let width = ges.translation.width
        setWithAnimation {
            if abs(width) > totalWidth * 0.15 && self.swiped != self.total - 1{
                self.offsets[self.swiped] = (width > 0 ? 1 : -1) * totalWidth
                self.swiped += 1
            }
            self.offset = 0
        }
    }
    
    public func refreshSwiped(){
        if self.swiped != 0 && !self.refresh{
            self.swiped = 0
            self.refresh = true
        }
    }
    
    public func refreshRefresh(_ refresh:Bool){
        setWithAnimation {
            if refresh{
                for count in 0..<self.total{
                    if self.offsets[count] != 0{
                        self.offsets[count] = 0
                    }
                }
                self.refresh = false
            }
        }
    }
    
    public func nextCard(){
        self.offsets[self.swiped] = (self.swiped % 2 == 0 ? -1 : 1) * totalWidth
        if self.swiped < self.total - 1{
            self.swiped += 1
        }
    }
    
    public func prevCard(){
        let newIdx = self.swiped - 1
        if newIdx >= 0{
            if self.offsets[newIdx] != 0{
                self.offsets[newIdx] = 0
            }
            self.swiped -= 1
        }
        
    }
}


public struct CardFanView<T:View>: View {
    
    @StateObject var SP:FanSwipedParams
    var indices:[Any]
    var viewBuilder:(Any) -> T
    var width:CGFloat
    var scrollable:Bool
    
    public init(width:CGFloat = totalWidth,indices:[Any],isScrollable:Bool = false,@ViewBuilder viewGen:@escaping (Any) -> T){
        self.indices = indices
        self.width = width
        self.viewBuilder = viewGen
        self.scrollable = isScrollable
        self._SP = .init(wrappedValue: .init(totalCards: indices.count))
    }
    
    var swiped:Int{
        self.SP.swiped
    }
    
    var offset:CGFloat{
        self.SP.offset
    }
    
    var offsets:[CGFloat]{
        self.SP.offsets
    }
    
    var refresh:Bool{
        self.SP.refresh
    }

    func cardScale(idx:Int) -> CGFloat{
        return idx > self.swiped ? (idx - self.swiped) <= 2 ? CGFloat(idx - self.swiped) * 0.05 : 0.1 : 0
    }

    @ViewBuilder func cardBuilder(idx:Int,data:Any) ->  some View{
        let x_offset = (self.swiped == idx ? self.offset : 0) + self.offsets[idx]
        let view = self.viewBuilder(data)
        if self.scrollable{
            view
                .gesture(DragGesture()
                            .onChanged({ gesVal in
                    if idx == self.swiped{
                        self.SP.onChanged(ges: gesVal)
                    }
                })
                            .onEnded({ gesVal in
                    if idx == self.swiped{
                        self.SP.onEnded(ges: gesVal)
                    }
                }))
                .offset(x: x_offset)
                .offset(y: -self.staticOffset(idx: idx))
                .scaleEffect(1 - self.cardScale(idx: idx))
        }else{
            view
                .offset(x: x_offset)
                .offset(y: -self.staticOffset(idx: idx))
                .scaleEffect(1 - self.cardScale(idx: idx))
        }
    }
    
    func staticOffset(idx:Int) -> CGFloat{
        let diff_idx = idx - self.swiped
        return (diff_idx) <= 2 ? CGFloat(diff_idx) * 25 : 50
    }

    
    func footerButtons() -> some View{
        HStack(alignment: .center, spacing: 10) {

            SystemButton(b_name: "arrow.left", color: .white,haveBG: true, size: .init(width: 10, height: 10),bgcolor: .clear,borderedBG: true,clipping: .circleClipping,action: self.SP.prevCard)
            Spacer()
            SystemButton(b_name: "arrow.clockwise", color: .white,haveBG: true, size: .init(width: 10, height: 10),bgcolor: .clear,borderedBG: true,clipping: .circleClipping,action: self.SP.refreshSwiped)
            Spacer()
            SystemButton(b_name: "arrow.right", color: .white,haveBG: true,size: .init(width: 10, height: 10), bgcolor: .clear, borderedBG: true,clipping: .circleClipping,action: self.SP.nextCard)
            
        }.padding()
        .frame(width: self.width, alignment: .center)
    }
               
    func onChangeFanCardSwipePreference(_ swipeDir:String){
        if swipeDir == CardFanSwipe.next.rawValue{
            self.SP.nextCard()
        }else if swipeDir == CardFanSwipe.prev.rawValue{
            self.SP.prevCard()
        }
        print("(DEBUG) swipeDir : ",swipeDir)
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .center) {
                ForEach(Array(self.indices.enumerated()).reversed(),id:\.offset) { idx_data in
                    let data = idx_data.element
                    let idx = idx_data.offset
                    if (idx >= self.swiped - 2 && idx <= self.swiped + 2) || idx == self.indices.count - 1{
                        self.cardBuilder(idx: idx, data: data)
                    }
                }
            }.frame(width: self.width, alignment: .center)
            self.footerButtons()
        }
        .animation(.spring(), value: self.swiped)
        .onChange(of: self.refresh,perform: self.SP.refreshRefresh(_:))
        .onPreferenceChange(FanSwipedPreferenceKey.self,perform:self.onChangeFanCardSwipePreference(_:))
        
    }
}
