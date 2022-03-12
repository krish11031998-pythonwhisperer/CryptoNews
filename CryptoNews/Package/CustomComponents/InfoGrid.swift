//
//  InfoGrid.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import SwiftUI

public struct InfoGrid<T:View>: View {
    var width:CGFloat
    var info:[String]
    var cols:Int
    var viewPopulator: (String) -> T
    
    public init(
        info:[String],
        width:CGFloat = totalWidth,
        cols:Int = 3,
        @ViewBuilder viewPopulator: @escaping (String) -> T){
        self.info = info
        self.width = width
        self.cols = cols
        self.viewPopulator = viewPopulator
    }
    
    
    var cardSpace:CGFloat{
        return self.width * 0.05
    }
    
    var cardWidth:CGFloat{
        return self.width/CGFloat(cols) - self.cardSpace
    }
    
    func view(key:String) -> some View{
        self.viewPopulator(key)
            .aspectRatio(contentMode: .fit)
            .frame(width: cardWidth, alignment: .center)
    }
    
    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: self.cardWidth, maximum: cardWidth), spacing: cardSpace, alignment: .center)], alignment: .leading, spacing: 15) {
            ForEach(self.info,id:\.self, content: self.view(key:))
        }
        .frame(width: width, alignment: .leading)
    }
}

//struct InfoGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoGrid()
//    }
//}
