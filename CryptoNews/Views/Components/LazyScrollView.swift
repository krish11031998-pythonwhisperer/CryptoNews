//
//  LazyScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct LazyScrollPreference:PreferenceKey{
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
    
}



struct LazyScrollView<T:View>: View {
    var data:[Any]
    var embedScrollView:Bool
    var viewGen: (Any) -> T
    @State var reloadNow:Bool = false
    var header:String?
    
    init(header:String? = nil,data:[Any],embedScrollView:Bool = false,@ViewBuilder viewGen: @escaping (Any) -> T){
        self.header = header
        self.data = data
        self.viewGen = viewGen
        self.embedScrollView = embedScrollView
    }
    
    
    var reloadContainer:some View{
        GeometryReader{g -> AnyView in
            
//            let minY = g.frame(in: .global).minY
            let maxY = g.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                if maxY < (totalHeight) && !self.reloadNow{
                    self.reloadNow.toggle()
                }
            }
            
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 100, alignment: .center))
        }
    }
    
    
    var refreshingView:some View{
        LazyVStack(alignment: .center, spacing: 10) {
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
        .preference(key: LazyScrollPreference.self, value: self.reloadNow)
    }
        
    var body: some View {
        if self.embedScrollView{
            ScrollView(.vertical, showsIndicators: false) {
                self.refreshingView
                    .padding(.vertical,50)
            }
        }else{
            self.refreshingView
        }
        
    }
}
