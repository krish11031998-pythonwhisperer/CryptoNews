//
//  ZoomInScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/03/2022.
//

import SwiftUI
import Combine

class CardFrameObserver{
    var data:Any
    var midX:CGFloat?
    var midY:CGFloat?
    var axis:Axis = .horizontal
    var centralize:Bool = false
    
    init(data:Any,midX:CGFloat? = nil,midY:CGFloat? = nil,axis:Axis = .horizontal,centeralize:Bool = false){
        self.data = data
        self.midX = midX
        self.midY = midY
        self.axis = axis
        self.centralize = centeralize
    }
    
    
    func updatePositionalValue(value offset:CGFloat){
        if self.axis == .horizontal{
            self.midX = offset
        }else{
            self.midY = offset
        }
    }
    
}

struct SelectedCentralCardPreferenceKey:PreferenceKey{
    static var defaultValue: Int = .zero
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}

struct ZoomInScrollView<T:View>: View {
    
    @State var components:Array<CardFrameObserver>
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    @State var centralIdx:Int = .zero
    var centralizeStart:Bool
    var axis:Axis
    var viewGen:(Any,CGSize,Bool) -> T
    var cardSize:CGSize
    var selectedCardSize:CGSize
    
    init(data:[Any],axis:Axis = .horizontal,centralizeStart:Bool = true,size:CGSize = .init(width: 300, height: 300),selectedCardSize:CGSize = .init(width: 300, height: 450),@ViewBuilder viewGen: @escaping (Any,CGSize,Bool) -> T){
        self.viewGen = viewGen
        self.cardSize = size
        self.selectedCardSize = selectedCardSize
        self.axis = axis
        self._components = .init(initialValue: data.enumerated().compactMap({.init(data: $0.element,axis:axis)}))
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
        self.centralizeStart = centralizeStart
    }

    
    func resetComponentsMapping(idx:Int){
        for count in 0..<self.components.count{
            self.components[count].updatePositionalValue(value: .zero)
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
        let leadPadding = self.centralizeStart && self.axis == .horizontal && idx == 0 ? totalWidth - size.width : 0
        let trailingPadding = self.centralizeStart && self.axis == .horizontal && idx == self.components.count - 1 ? totalWidth - size.width : 0
        let topPadding = self.centralizeStart && self.axis == .vertical && idx == 0 ? totalHeight - size.height : 0
        let bottomPadding = self.centralizeStart && self.axis == .vertical && idx == self.components.count - 1 ? totalHeight - size.height : 0
        GeometryReader{ g -> AnyView in

            let midX = g.frame(in: .global).midX
            let midY = g.frame(in: .global).midY
            
            DispatchQueue.main.async {
                self.components[idx].updatePositionalValue(value: self.axis == .horizontal ? midX : midY)
            }
            
            return self.viewGen(data,.init(width: size.width, height: size.height),self.centralIdx == idx)
                .anyViewWrapper()
        }
        .frame(width: size.width, height: size.height * 1.1, alignment: .center)
        .padding(.leading,leadPadding * 0.5)
        .padding(.trailing,trailingPadding * 0.5)
        .padding(.top,topPadding * 0.5)
        .padding(.bottom,bottomPadding * 0.5)
        
    }
    
    var observedValue:[CGFloat]{
        return self.components.compactMap({self.axis == .horizontal ? $0.midX : $0.midY})
    }
    
    var scrollViewAxis:Axis.Set{
        return self.axis == .vertical ? .vertical : .horizontal
    }
    
    func updateOnScrollEnd(scrollProxy:ScrollViewProxy,value:CGFloat){
        print("Stopped on: \(value)")
        let closestIdx = self.Centralizationhandler()
        setWithAnimation {
            scrollProxy.scrollTo(closestIdx, anchor: .center)
            self.resetComponentsMapping(idx: closestIdx)
            self.centralIdx = closestIdx
        }
    }
    
    @ViewBuilder var innerView:some View{
        if self.axis == .horizontal{
            HStack {
                ForEach(Array(self.components.enumerated()), id:\.offset) { _component in
                    let component = _component.element
                    let idx = _component.offset
                    
                    self.cardBuilder(data: component.data, idx: idx)
                        .id(idx)
                }
            }
        }else{
            VStack {
                ForEach(Array(self.components.enumerated()), id:\.offset) { _component in
                    let component = _component.element
                    let idx = _component.offset
                    
                    self.cardBuilder(data: component.data, idx: idx)
                        .id(idx)
                }
            }
        }
    }

    
    var scrollViewObserver:some View{
        GeometryReader { g in
            let origin = g.frame(in: .named("scroll")).origin
            let diffValue = self.axis == .vertical ? -origin.y : origin.x
            Color.clear.preference(key: ViewOffsetKey.self, value: diffValue)
        }
    }
    
    @ViewBuilder var scrollView:some View{
        if !self.components.isEmpty{
            ScrollViewReader { scrollProxy in
                ScrollView(self.scrollViewAxis, showsIndicators: false){
                    self.innerView
                    .background(self.scrollViewObserver)
                    .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
                }
                .coordinateSpace(name: "scroll")
                .onReceive(publisher){ value in
                    self.updateOnScrollEnd(scrollProxy:scrollProxy,value: value)
                }
            }
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    
    func Centralizationhandler() -> Int{
        var lowestMid:CGFloat = .greatestFiniteMagnitude
        var lowestIdx:Int = .zero
        for count in 0..<self.observedValue.count{
            let midValue = self.observedValue[count]
            let refVal = self.axis == .horizontal ? halfTotalWidth : totalHeight * 0.5
            let diffMid = abs(refVal - midValue)
            if diffMid < lowestMid{
                lowestMid = diffMid
                lowestIdx = count
            }
        }
        print("(DEBUG) Lowest idx : ",lowestIdx)
        return lowestIdx
    }
    
    var body: some View {
        self.scrollView
            .preference(key: SelectedCentralCardPreferenceKey.self, value: self.centralIdx)
            .animation(.easeInOut)
    }
}

struct ZoomInScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomInScrollView(data: [Color.red,Color.blue,Color.yellow,Color.gray,Color.green],axis: .horizontal) { data, size, _ in
            
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
