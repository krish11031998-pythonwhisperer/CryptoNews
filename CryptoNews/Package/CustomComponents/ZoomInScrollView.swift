//
//  ZoomInScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/03/2022.
//

import SwiftUI

struct CardFrameObserver{
    var data:Any
    var midX:CGFloat?
    var midY:CGFloat?
    var centralize:Bool = false
}

struct SelectedCentralCardPreferenceKey:PreferenceKey{
    static var defaultValue: Int = .zero
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}

struct ZoomInScrollView<T:View>: View {
    
    @State var components:Array<CardFrameObserver>
    @State var scrolling:Bool = false
    @State var centralIdx:Int = .zero
    @State var firstLoad:Bool = true
    @State var offset:CGFloat = .zero
    var viewGen:(Any,CGSize) -> T
    var cardSize:CGSize
    var selectedCardSize:CGSize
    
    init(data:[Any],size:CGSize = .init(width: 300, height: 300),selectedCardSize:CGSize = .init(width: 300, height: 450),@ViewBuilder viewGen: @escaping (Any,CGSize) -> T){
        self._components = .init(initialValue: data.compactMap({CardFrameObserver(data: $0)}))
        self.viewGen = viewGen
        self.cardSize = size
        self.selectedCardSize = selectedCardSize
    }
    
    func scrollElementObserver(value:CGFloat,idx:Int){
        if self.centralIdx == idx{
            if self.firstLoad{
                self.offset = halfTotalWidth - value
                self.firstLoad.toggle()
            }else{
                if !self.scrolling && self.components[idx].midX != value{
                    self.scrolling.toggle()
                }else if self.scrolling && self.components[idx].midX == value{
                    self.scrolling.toggle()
                }
            }
        }
        if self.components[idx].midX != value{
           self.components[idx].midX = value
       }
    }
    
    func dynamicCardSize(idx:Int) -> CGSize{
        if self.centralIdx == idx{
            return self.selectedCardSize
        }else{
            return self.cardSize
        }
    }
    
    func dynamicScale(idx:Int) -> CGFloat{
        if self.centralIdx == idx{
            return 1.1
        }else{
            return 1
        }
    }
    
    @ViewBuilder func cardBuilder(data:Any,idx:Int) -> some View{
        let size = self.dynamicCardSize(idx: idx)
        let scale = self.dynamicScale(idx: idx)
        GeometryReader{ g -> AnyView in

            let midX = g.frame(in: .global).midX
            
            DispatchQueue.main.async {
                self.scrollElementObserver(value: midX, idx: idx)
            }
            
            return self.viewGen(data,.init(width: size.width * scale, height: size.height * scale)).anyViewWrapper()
        }
        .frame(width: size.width * scale, height: size.height * scale, alignment: .center)
        .padding(scale != 1 ? 15 : 0)
        
    }
    
    var observedValue:[CGFloat]{
        return self.components.compactMap({$0.midX ?? $0.midY})
    }
    
    @ViewBuilder var scrollView:some View{
        if !self.components.isEmpty{
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(self.components.enumerated()), id:\.offset) { _component in
                            let component = _component.element
                            let idx = _component.offset

                            self.cardBuilder(data: component.data, idx: idx)
                                .id(idx)
                        }
                    }.padding(.horizontal,self.offset)
                }
                .onChange(of: self.scrolling) { isScrolling in
                    if !self.firstLoad && !scrolling && self.inCentralizeMotion{
                        print("(DEBUG) Not Scrolling")
                        if let idx = self.Centralizationhandler(),self.centralIdx != idx{

                            DispatchQueue.main.async {
                                self.components = self.components.compactMap({.init(data: $0.data)})
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                                withAnimation(.easeInOut){
                                    self.centralIdx = idx
                                    scrollProxy.scrollTo(idx, anchor: .trailing)
                                    
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    
    var inCentralizeMotion:Bool{
        return self.components.compactMap({$0.midX ?? $0.midY}).reduce(false, {$0 || $1 != 0})
    }
    
    
    func Centralizationhandler() -> Int?{
        if self.inCentralizeMotion{
            var lowestMid:CGFloat = .greatestFiniteMagnitude
            var lowestIdx:Int = .zero
            for count in 0..<self.observedValue.count{
                let midValue = self.observedValue[count]
                let diffMid = abs(halfTotalWidth - midValue)
                if diffMid < lowestMid{
                    lowestMid = diffMid
                    lowestIdx = count
                }
            }
            print("(DEBUG) Lowest idx : ",lowestIdx)
                        
            return lowestIdx
        }
        return nil
    }
    
    var body: some View {
        self.scrollView
            .preference(key: SelectedCentralCardPreferenceKey.self, value: self.centralIdx)
            
    }
}

struct ZoomInScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomInScrollView(data: [Color.red,Color.blue,Color.yellow,Color.gray,Color.green]) { data, size in
            
            if let color = data as? Color{
                Rectangle()
                    .fill(color)
                    .clipContent(clipping: .roundClipping)
            }else{
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            }
            
        }
    }
}
