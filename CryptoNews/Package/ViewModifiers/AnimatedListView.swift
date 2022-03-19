//
//  AnimatedListView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/03/2022.
//

import SwiftUI

struct AnimatedListView<Content:View>: View {
    
    var viewGen:(Any) -> Content
    var data:[Any]
    @State var idx:Int = 5
    
    init(data:[Any],@ViewBuilder viewGen:@escaping (Any) -> Content){
        self.data = data
        self.viewGen = viewGen
    }
    
    var positionReaderView:some View{
        GeometryReader{g -> Color in
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if minY < totalHeight{
                    self.idx += 5
                }
            }
            
            return Color.clear
        }
    }
    
    var selectedData:[Any]{
        return self.idx > data.count ? data : Array(data[0..<idx])
    }
    
    @ViewBuilder func listObserver(idx:Int) -> some View{
        if idx == self.selectedData.count - 1{
            self.positionReaderView
        }else{
            Color.clear
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 7.5) {
            ForEach(Array(self.selectedData.enumerated()),id:\.offset) { _data in
                let data  = _data.element
                let idx = _data.offset
                self.viewGen(data)
                    .animatedAppearance(idx:idx)
            }
        }
    }
}

//struct AnimatedListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatedListView()
//    }
//}
