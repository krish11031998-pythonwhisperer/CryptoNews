//
//  InfoGrid.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import SwiftUI

struct InfoGrid<T:View>: View {
    var width:CGFloat
    var info:[String]
    var viewPopulator: (String) -> T
    
    init(
        info:[String],
        width:CGFloat = totalWidth,
        @ViewBuilder viewPopulator: @escaping (String) -> T
    ){
        self.info = info
        self.width = width
        self.viewPopulator = viewPopulator
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: width * 0.3, maximum: width * 0.3), spacing: width * 0.05, alignment: .center)], alignment: .leading, spacing: 15) {
            ForEach(self.info,id:\.self, content: self.viewPopulator)
        }
        .frame(width: width, alignment: .leading)
    }
}

//struct InfoGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoGrid()
//    }
//}
