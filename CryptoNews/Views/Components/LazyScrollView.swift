//
//  LazyScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct LazyScrollView<T:View>: View {
    var data:[Any]
    var viewGen: (Any) -> T
    var reload:() -> Void
    @State var reloadNow:Bool = false
    
    init(data:[Any],@ViewBuilder viewGen: @escaping (Any) -> T, reload: @escaping () -> Void){
        self.data = data
        self.viewGen = viewGen
        self.reload = reload
    }
    
    
    func reload(idx:Int){
        if idx == self.data.count - 5{
            self.reload()
        }
    }
    
    var reloadContainer:some View{
        GeometryReader{g -> AnyView in
            
//            let minY = g.frame(in: .global).minY
            let maxY = g.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                if maxY < (totalHeight) && !self.reloadNow{
                    self.reloadNow.toggle()
                    self.reload()
                }
            }
            
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 100, alignment: .center))
        }
    }
    
    
    var refreshingView:some View{
        VStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()), id:\.offset) {_data in
                let data = _data.element
                self.viewGen(data)
            }
            self.reloadContainer
                .padding(.bottom,200)
        }.onChange(of: self.data.count) { newCount in
            if self.reloadNow{
                self.reloadNow.toggle()
            }
        }
    }
    
    var body: some View {
        self.refreshingView
    }
}
