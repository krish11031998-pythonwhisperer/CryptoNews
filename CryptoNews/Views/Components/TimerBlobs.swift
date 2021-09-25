//
//  TimerBlobs.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/08/2021.
//

import SwiftUI

struct TimerBlobs: View {
    @Binding var time:Int
    var targetTime:Int
    var color = Color.mainBGColor
    var text:String
    var active:Bool
    var height:CGFloat
    
    init(text:String,h:CGFloat,time:Binding<Int>,targetTime:Int,active:Bool){
        self.text = text
        self.height = h
        self._time = time
        self.targetTime = targetTime
        self.active = active
    }

    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).size.width
            let h = g.frame(in: .local).size.height
            
            ZStack(alignment: .leading) {
                self.color.opacity(0.5)
                if self.active{
                    self.color.opacity(0.5).frame(width: w * CGFloat(Float(self.time)/Float(self.targetTime)), height: h, alignment: .leading)
                }
                MainText(content: self.text, fontSize: 15, color: .white, fontWeight: .regular)
                    .frame(width: w, alignment: .center)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        }.padding(10)
        .frame(height: self.height, alignment: .leading)
        .frame(minWidth: 50,maxWidth: 100)
//        .aspectRatio(contentMode: .fit)
        
            
    }
}

//struct TimerBlobs_Previews: PreviewProvider {
//    static var previews: some View {
//        TimerBlobs()
//    }
//}
