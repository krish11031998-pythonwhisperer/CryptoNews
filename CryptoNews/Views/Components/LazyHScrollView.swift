//
//  LazyHScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/02/2022.
//

import SwiftUI

struct LazyHScrollView<T:View>: View {
    
    var viewBuilder:(Any) -> T
    var data:[Any]
    @State var offset:Int = .zero
    
    init(pageData:[Any],@ViewBuilder builder: @escaping (Any) -> T){
        self.data = pageData
        self.viewBuilder = builder
    }
    
    var cardCountlimit:Int{
        return 3
    }
    
    var cardsCount:Int{
        return self.data.count > cardCountlimit ? cardCountlimit : self.data.count
    }
    
    var cardsData:[Any]{
        return Array(self.data[0..<(self.cardsCount + self.offset)])
    }
    
    
    @ViewBuilder func cardBuilder(idx:Int) -> some View{
        let data = self.data[idx]
        
        if let last = self.cardRange.last,idx == last{
            GeometryReader{g -> AnyView in
                
                let minX = g.frame(in: .global).minX
                
                setWithAnimation {
                    if minX <= totalWidth && (self.offset + self.cardsCount) + 1 < self.data.count{
                        self.offset += 1
                    }else if minX > totalWidth && (self.offset + self.cardsCount) - 1 > self.cardCountlimit {
                        self.offset -= 1
                    }
                }
                
                return AnyView(self.viewBuilder(data))
            }.aspectRatio(contentMode: .fit)
        }else{
            self.viewBuilder(data)
        }
    }
    
    var cardRange:[Int]{
        return Array(0..<self.offset + self.cardsCount)
    }
    

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(self.cardRange,id: \.self){ idx in
                    self.cardBuilder(idx: idx)
                }
            }
        }.animation(.easeInOut,value:self.offset)
    }
}

struct LazyHScrollView_Previews: PreviewProvider {
    static var previews: some View {
        LazyHScrollView(pageData: [1,2,3,4,5,6,7,8,9,10]) { data in
            if let idx = data as? Int{
                switch(idx){
                    case 1:
                        Color
                            .red
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                    case 2:
                        Color
                            .green
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                    case 3:
                        Color
                            .yellow
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                    case 4:
                        Color
                            .blue
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                    case 5:
                        Color
                            .pink
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                    default:
                        BlurView
                            .thinLightBlur
                            .frame(width: 200, height: 350, alignment: .center)
                            .clipContent(clipping: .roundClipping)
                }
            }else{
                Color
                    .mainBGColor
                    .frame(width: 200, height: 350, alignment: .center)
                    .clipContent(clipping: .roundClipping)
            }
                    
        }
        .padding(.vertical)
        .aspectRatio(contentMode: .fit)
        .animation(.easeInOut)
        .background(Color.mainBGColor)
//            .ignoresSafeArea()
    }
}
