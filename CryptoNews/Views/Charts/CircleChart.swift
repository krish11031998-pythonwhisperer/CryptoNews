//
//  CircleChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 07/06/2021.
//

import SwiftUI

struct CircleChart: View {
    var percent:Float
    var header:String?
    var size:CGSize
    var increase:Bool
    var infoView:AnyView?
    var widthFactor:CGFloat
    
    init(percent:Float,header:String? = nil,size:CGSize = .init(width: totalWidth * 0.45, height: 300),widthFactor:CGFloat = 0.075,infoView:AnyView? = nil){
        self.percent = percent
        self.header = header
        self.size = size
        self.increase = true
        self.infoView = infoView
        self.widthFactor = widthFactor
    }

    
    var percentObj:(CGFloat,Color){
        let percent = CGFloat(self.percent/100)
        let color:Color = self.percent > 60 ? .green : self.percent > 40 ? .yellow : .red
        return (percent,color)
    }
    
    @ViewBuilder func CircleChart(w:CGFloat,h:CGFloat) -> some View{
        let chartW = w * 0.8
        let (percent,color) = self.percentObj
        ZStack(alignment: .center) {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.125), lineWidth: w * self.widthFactor)
                .frame(width: chartW, height: chartW, alignment: .center)
            Circle()
                .trim(from: 0, to: percent)
                .stroke(color, lineWidth: w * self.widthFactor)
                .frame(width: chartW , height: chartW , alignment: .center)
                .rotationEffect(.init(degrees: -90), anchor: .center)
            if let infoView = infoView {
                infoView
            }
        }.frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if let header = header {
                ChartCard(header: header, size: self.size, insideView: self.CircleChart(w:h:))
            }else{
                self.CircleChart(w: self.size.width, h: self.size.height)
            }
        }
    }
}

struct CircleChart_Previews: PreviewProvider {
    static var previews: some View {
        CircleChart(percent: 35, header: "Likes")
    }
}
