//
//  BarChart.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 18/09/2021.
//

import SwiftUI

struct BarElement{
    var data:Float
    var axis_key:String
    var key:String
    var info_data:Float
}


struct BarChart: View {
    var heading:String = ""
    var size:CGSize = .zero
    @State var selected:Int = -1
    var bar_elements:[BarElement] = []
    init(heading:String,bar_elements:[BarElement] = [],size:CGSize = .init(width: totalWidth * 0.75, height: totalHeight * 0.4)){
        self.bar_elements = bar_elements
        self.heading = heading
        self.size = size
    }
    
    var dataPoints:[Float]{
        return self.bar_elements.compactMap({$0.data})
    }
    
    var axis_keys:[String]{
        return self.bar_elements.compactMap({$0.axis_key})
    }
    
    var keys:[String]{
        return self.bar_elements.compactMap({$0.key})
    }
    
    var info_data:[Float]{
        return self.bar_elements.compactMap({$0.info_data})
    }
    
    var totalOfDataPoints:Float{
        return self.dataPoints.reduce(0, {$0 + $1})
    }
    
    func barElement(bar_val _data:EnumeratedSequence<[Float]>.Element,size:CGSize) -> some View{
        let data = _data.element
        let idx = _data.offset
        let bar_w = size.width
        let bar_h_factor = CGFloat(data/self.totalOfDataPoints) < 0.1 ? 0.1 : CGFloat(data/self.totalOfDataPoints)
        let key = (idx + 1) > axis_keys.count ? "😞" : axis_keys[idx]
        let bar_h = bar_h_factor * size.height * 0.9

        return VStack(alignment: .center, spacing: 10){
            RoundedRectangle(cornerRadius: bar_w * 0.5)
                .foregroundColor(.white)
                .frame(width: bar_w, height: bar_h, alignment: .bottom)
                .scaleEffect(self.selected == idx ? 1.1 : 1)
            MainText(content: key, fontSize: 12, color: .white)
                .frame(width:bar_w,height:size.height * 0.1)
        }
        .buttonify {
            withAnimation(.easeInOut) {
                self.selected = self.selected == idx ? -1 : idx
            }
        }
    }
    
    func barChart(size:CGSize) -> some View {
        let spacing:CGFloat = 10
        let bar_w = size.width/CGFloat(self.dataPoints.count) - spacing
        return LazyHStack(alignment: .bottom, spacing: spacing){
            ForEach(Array(self.dataPoints.enumerated()), id: \.offset) { _data in
                self.barElement(bar_val: _data, size: .init(width: bar_w, height: size.height))
            }
        }.frame(width: size.width, height: size.height, alignment: .bottom)
        
    }
    
    func headLineText(heading:String,subText:String) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: 12)
            MainText(content: subText, fontSize: 15,fontWeight: .semibold)
        }.frame(alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    func chartInfoView(size:CGSize) -> some View{
        return HStack(alignment: .bottom,spacing: 10){
            self.headLineText(heading: "Sentiment", subText: keys[self.selected])
            Spacer(minLength: size.width * 0.2)
            self.headLineText(heading: "Social Impact Score", subText:  String(format:"%.0f",info_data[self.selected]))
        }.padding(5)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }
    
    func ChartView(size:CGSize) -> some View{
        let bar_w = size.width
        let bar_h  = size.height * (self.selected == -1 ? 0.9 : 0.7)
        return VStack(alignment: .leading, spacing: 10){
            self.barChart(size: .init(width: bar_w, height: bar_h))
            if self.selected != -1{
                self.chartInfoView(size:.init(width: bar_w, height: size.height * 0.2 - 10))
            }
        }.frame(width: size.width, height: size.height, alignment: .topLeading)
    }
    
    var body: some View {
        ChartCard(header: self.heading, size: self.size,aR: .fill) { w, h in
            return AnyView(self.ChartView(size: .init(width: w, height: h)))
        }
//        .animation(.easeInOut)
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(heading:"Test",bar_elements: [BarElement(data: 75, axis_key: "🐻", key: "Very Bearish", info_data: 90892),BarElement(data: 15, axis_key: "😞", key: "Bearish", info_data: 908),BarElement(data: 150, axis_key: "😐", key: "Normal", info_data: 90098),BarElement(data: 190, axis_key: "☺️", key: "Bullish", info_data: 9098),BarElement(data: 50, axis_key: "🐂", key: "Very Bullish", info_data: 9098)], size: .init(width: totalWidth, height: totalHeight * 0.5))
    }
}

