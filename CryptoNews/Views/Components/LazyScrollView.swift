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
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()), id:\.offset) {_data in
                let data = _data.element
                let idx = _data.offset
                
                self.viewGen(data)
                    .onAppear {
                        self.reload(idx: idx)
                    }
                
            }
            ProgressView().padding(.bottom,25).frame(alignment:.center)
        }
    }
}

//struct LazyScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        LazyScrollView()
//    }
//}
