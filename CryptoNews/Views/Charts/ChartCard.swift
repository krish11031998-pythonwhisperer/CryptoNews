//
//  ChartCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 13/06/2021.
//

import SwiftUI

struct ChartCard<T:View>: View {
    var header:String
    var size:CGSize
    var insideView:((CGFloat,CGFloat) -> T)
    var aR:ContentMode
    
    init(header:String = "Header",size:CGSize  = .init(width: totalWidth * 0.5, height: totalHeight * 0.5),aR:ContentMode = .fill, @ViewBuilder insideView:@escaping ((CGFloat,CGFloat) -> T)){
        self.header = header
        self.size = size
//        if let safeView = insideView{
        self.insideView = insideView
//        }
        self.aR = aR
    }

    func infoView(w:CGFloat,h:CGFloat) -> some View{
        return ZStack(alignment: .center){
            Color.gray.opacity(0.5)
            
        }.frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            VStack(alignment: .center, spacing: 10){
                MainText(content: self.header, fontSize: 20, color: .white, fontWeight: .semibold,style: .heading)
                    .frame(width: w,alignment: .leading)
//                if let safeIS = self.insideView{
                insideView(w,h * 0.95)
//                }
            }
        }
        .padding(self.aR == .fill ? 15 : 0)
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 2)
    }
}

//struct ChartCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartCard()
//    }
//}
