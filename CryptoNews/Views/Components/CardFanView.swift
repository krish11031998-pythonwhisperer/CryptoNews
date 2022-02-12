//
//  CardFanView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/02/2022.
//

import SwiftUI

class FanSwipedParams:ObservableObject{
    @Published var swiped:Int = .zero
    @Published var offset:CGFloat = .zero
    @Published var offsets:[CGFloat]
    @Published var refresh:Bool = false
    var total:Int
    
    init(totalCards:Int){
        self.total = totalCards
        self._offsets = .init(wrappedValue: .init(repeating: 0.0, count: totalCards))
    }
    
    func onChanged(ges:DragGesture.Value){
        let width = ges.translation.width
        if self.swiped < self.total - 1{
            setWithAnimation {
                self.offset = width
            }
        }
    }
    
    func onEnded(ges:DragGesture.Value){
        let width = ges.translation.width
        setWithAnimation {
            if abs(width) > totalWidth * 0.15 && self.swiped != self.total - 1{
                self.offsets[self.swiped] = (width > 0 ? 1 : -1) * totalWidth
                self.swiped += 1
            }
            self.offset = 0
        }
    }
    
    func refreshSwiped(){
        if self.swiped != 0 && !self.refresh{
            self.swiped = 0
            self.refresh = true
        }
    }
    
    func refreshRefresh(_ refresh:Bool){
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
    
    func nextCard(){
        self.offsets[self.swiped] = (self.swiped % 2 == 0 ? -1 : 1) * totalWidth
        if self.swiped < self.total - 1{
            self.swiped += 1
        }
    }
    
    func prevCard(){
        let newIdx = self.swiped - 1
        if newIdx >= 0{
            if self.offsets[newIdx] != 0{
                self.offsets[newIdx] = 0
            }
            self.swiped -= 1
        }
        
    }
}


struct CardFanView<T:View>: View {
    
    @StateObject var SP:FanSwipedParams
    var indices:[Any]
    var viewBuilder:(Any) -> T
    var width:CGFloat
    var scrollable:Bool
    
    init(width:CGFloat = totalWidth,indices:[Any],isScrollable:Bool = false,@ViewBuilder viewGen:@escaping (Any) -> T){
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
//            .overlay(MainText(content: "\(idx + 1)", fontSize: 25,fontWeight: .bold),alignment:.center)
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

    var body: some View {
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
        }.animation(.spring(), value: self.swiped)
            .onChange(of: self.refresh,perform: self.SP.refreshRefresh(_:))
        
    }
}

struct CardFanView_Previews: PreviewProvider {
    static var previews: some View {
        CardFanView(indices: Array(repeating: 0, count: 15).map({_  in Color.random})){ data in
            
            if let color = data as? Color{
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .frame(width: 400, height: 450, alignment: .center)
            }else{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.mainBGColor)
                    .frame(width: 400, height: 450, alignment: .center)
            }
            
        }.background(mainBGView.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
        
    }
}
