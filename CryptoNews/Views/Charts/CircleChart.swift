//
//  CircleChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 07/06/2021.
//

import SwiftUI

struct CircleChart: View {
    @State var percent:Float = 0
    var Percent:Float
    var header:String
    var size:CGSize
    var increase:Bool
    var infoView:AnyView
    
    init(percent:Float,header:String,size:CGSize = .init(width: totalWidth * 0.45, height: 300),infoView:AnyView = AnyView(Color.clear)){
        self.Percent = percent
        self.header = header
        self.size = size
        self.increase = true
        self.infoView = infoView
    }
    
    func onAppear(){
        withAnimation(.easeInOut) {
            self.percent = Percent
        }
    }
    
    @ViewBuilder func CircleChart(w:CGFloat,h:CGFloat) -> some View{
        let chartW = w * 0.8
        ZStack(alignment: .center) {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.125), lineWidth: w * 0.045)
                .frame(width: chartW, height: chartW, alignment: .center)
            Circle()
                .trim(from: 0, to: CGFloat(self.percent/100))
                .stroke(Color.green.opacity(0.75), lineWidth: w * 0.045)
                .frame(width: chartW , height: chartW , alignment: .center)
                .rotationEffect(.init(degrees: -90), anchor: .center)
            self.infoView
        }.frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        ChartCard(header: self.header, size: self.size, insideView: self.CircleChart(w:h:))
//            .animation(.easeInOut)
            .onAppear(perform: self.onAppear)
    }
}

struct CircleChart_Previews: PreviewProvider {
    static var previews: some View {
        CircleChart(percent: 35, header: "Likes")
    }
}
