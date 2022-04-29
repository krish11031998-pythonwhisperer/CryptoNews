//
//  EventView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 28/04/2022.
//

import SwiftUI

struct EventSnapshot: View {
    var event:CrybseEventData
    var width:CGFloat
    var height:CGFloat?
    
    init(event:CrybseEventData,width:CGFloat = totalWidth,height:CGFloat? = nil){
        self.event = event
        self.width = width
        self.height = height
    }
    
    @ViewBuilder func header(w:CGFloat) -> some View{
        if let safeEventName = self.event.event_name,let safeNewsCount = self.event.news_items{
            VStack(alignment: .leading, spacing: 10) {
                MainText(content: safeEventName, fontSize: 22.5, color: .white, fontWeight: .medium)
//                MainText(content: "News : \(safeNewsCount)", fontSize: 10, color: .white, fontWeight: .medium)
//                    .textBubble(color: .white, clipping: .roundClipping, verticalPadding: 10, horizontalPadding: 10)
                Spacer()
                HStack(alignment: .bottom) {
                    MainText(content: "Sentiment", fontSize: 17.5, color: .gray.opacity(0.5), fontWeight: .semibold)
                    Spacer()
                    MainText(content: "Positive", fontSize: 20, color: .green, fontWeight: .medium)
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: w * 0.75, height: 5, alignment: .leading)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: w * 0.25, height: 5, alignment: .leading)
                }
                
                HStack(alignment: .center, spacing: 10) {
                    MainText(content: "News Count", fontSize: 17.5, color: .gray.opacity(0.5), fontWeight: .semibold)
                    Spacer()
                    MainText(content: "\(self.event.news_items ?? 0)", fontSize: 20, color: .white, fontWeight: .medium)
                }
                
                
            }
            .frame(width: w, alignment: .leading)
        }
    }
    
    var body: some View {
        Container(width: self.width,horizontalPadding: 20,verticalPadding: 20) { w in
            self.header(w: w)
            if let tickers = self.event.tickers,self.height == nil{
                CustomWrappedTextHStack(data: tickers, width: w,fontSize: 11)
            }
        }
    }
}

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}
