//
//  CurveChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 17/06/2021.
//

import SwiftUI

struct CurveChart: View {
    var data:[Float]
    var size:CGSize = .init(width: totalWidth, height: 300)
    @State private var load:Bool = false
    @State var selected:Int = -1
    @Binding var choosen:Int
    @State var location:CGPoint = .zero
    @State var points:[CGPoint] = []
    var interactions:Bool
    var header:String? = nil
    var bgColor:Color
    var lineColor:Color?
    var chartShade:Bool
    var useSelected:Bool = true
    
    init(data:[Float],choosen:Binding<Int>? = nil,interactions:Bool = true,size:CGSize? = nil,header:String? = nil,bg:Color = .white,lineColor:Color? = nil,chartShade:Bool = true){
        self.interactions = interactions
        self.data = data
        if let s = size{
            self.size = s
        }
        self.header = header
        self.bgColor = bg
        self.lineColor = lineColor
        self.chartShade = chartShade
        if choosen != nil{
            self.useSelected = false
        }
        self._choosen = choosen ?? .constant(-1)
    }
    

    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            withAnimation(.linear(duration: 0.75)) {
                self.load = true
            }
        }
    }
    
    func updatePoints(points:[CGPoint]){
        if self.points.isEmpty{
            self.points = points
        }
    }
    
    func path(size:CGSize,step:CGSize) -> some View{
        let stepWidth = step.width
        let stepHeight = step.height
//        let color = self.chartShade ? self.lineColor : Color.clear
        return ZStack(alignment: .leading){
            Path.drawCurvedChart(dataPoints: self.dataPoints, step: .init(x: stepWidth, y: stepHeight))
                .trim(from: 0, to: self.load ? 1 : 0)
                .stroke(self.gradientColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))

            if self.selected != -1 || self.choosen != -1{
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10, alignment: .bottom)
                    .offset(x: self.location.x - 5, y: self.location.y + 10)
                
            }
        }
        .rotationEffect(.degrees(180), anchor: .center)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .padding(.bottom,25)
        .frame(width: size.width, height: size.height, alignment: .center)
//        .background(Color.red)
        .gesture(DragGesture()
                    .onChanged({ value in
                        self.onChanged(size: size, step: .init(x: stepWidth, y: stepHeight), value: value)
                    })
                    .onEnded(self.onEnded(value:))
        )
        
    }
    
    func chart(width:CGFloat, height:CGFloat) -> AnyView{
        return AnyView(GeometryReader{g in
            
            let w = g.size.width
            let h = g.size.height
            let chart_w = w * 0.95
            let stepWidth = chart_w / CGFloat(self.data.count - 1)
            let stepHeight = self.calcStepHeight(h: h - 40)

            ZStack(alignment: .bottom){
                self.path(size:.init(width: chart_w, height: h),step: .init(width: stepWidth, height: stepHeight))
                    .frame(width: w, height: h, alignment: .center)
                    .background(self.bgColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                    .onAppear(perform: self.onAppear)
                if self.selected != -1 || self.choosen != -1{
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: self.size.height, alignment: .leading)
                        .offset(x: self.location.x - (w * 0.5))
                }
            }.frame(width: w, height: h, alignment: .leading)
            
        }
//        .padding(.horizontal,5)
        .frame(width: width, height: height, alignment: .center))
    }
    
    
    var body: some View {
        self.chart(width: size.width, height: size.height)
    }
}

extension CurveChart{
    
    var stepHeight:CGFloat{
        guard let min = self.data.min(), let max = self.data.max(), min != max else {return 0}
        return self.size.height / CGFloat(max - min)
    }
    
    var stepWidth:CGFloat{
        return self.size.width/CGFloat(self.data.count)
    }
    
    func calcStepHeight(h:CGFloat) -> CGFloat{
        guard let min = self.data.min(), let max = self.data.max(), min != max else {return 0}
        return h / CGFloat(max - min)
    }
    
    var annotationCardSize:CGSize{
        return .init(width: size.width * 0.3, height: size.height * 0.35)
    }
    
    var gradientColor:LinearGradient{
        guard let lineColor = self.lineColor else {return Color.mainBGColor}
        return LinearGradient(gradient: .init(colors: [lineColor,lineColor.opacity(0.875),lineColor.opacity(0.75)]), startPoint: .trailing, endPoint: .leading)
    }
    
    var dataPoints:[CGFloat]{
        let min = self.data.min() ?? 0
        return self.data.compactMap({CGFloat($0 - min)})
    }
    
    func valueInfo(width w:CGFloat, height h:CGFloat) -> AnyView{
        func subsectionInfo(idx:Int) -> some View{
            
            let headline = idx == self.selected ? "Now" : "Last"
            let value = self.data[idx]
            let diff = idx != self.selected && idx > 0 ? self.data[idx] - self.data[idx - 1] : 0
            let color  = idx == self.selected ? Color.white :  diff > 0 ? Color.green : Color.red
            let fontColor = idx == self.selected ? Color.black : Color.white
            let view = VStack(alignment: .leading, spacing: 2.5){
                MainText(content: headline, fontSize: 10.5, color: fontColor, fontWeight: .regular)
                MainText(content: String(format: "%.1f",value), fontSize: 14.5, color: fontColor, fontWeight: .semibold)
            }
            .padding(5)
            .frame(width: w * 0.5, height: h, alignment: .center)
            .background(color)
            
            return view
        }
        if self.selected == -1 {return AnyView(Color.clear.frame(width: w, height: h, alignment: .center))}
        let x_off = self.location.x - w * 0.5 < 0 ? 10 : self.location.x + w > self.size.width ? self.size.width - w - 40 : self.location.x - w * 0.5
        
        return AnyView(HStack(alignment: .center, spacing: 0){
            subsectionInfo(idx: self.selected)
            if self.selected > 0 {
                subsectionInfo(idx: self.selected - 1)
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: h - 10, alignment: .center)
        .frame(minWidth: w * 0.5)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 0)
        .offset(x: x_off)
        .padding(.bottom,10)
        )
        
    }
    
    func onChanged(size:CGSize,step:CGPoint,value:DragGesture.Value){
        if !self.interactions{return}
        let location = value.location
        let x = location.x
//        let y = location.y
        let num = Int(x/step.x)
        if num >= self.dataPoints.count || num < 0 {return}
        let x_off = CGFloat(num) * step.x
//        let x_off = x
        
        func delta() -> CGFloat{
            let diff = self.dataPoints[num + 1] - self.dataPoints[num]
            let factor = CGFloat(x/step.x)
            return diff * factor
        }
        
        let static_off = self.dataPoints[num] * step.y - size.height * 0.5
        let y_off = static_off
        
        
        withAnimation(.easeInOut) {
            self.location = .init(x: x_off, y: y_off)
//            self.location = location
            let val = num >= 0 && num < self.data.count ? num : -1
            if useSelected{
                self.selected = val
            }else{
                self.choosen = val
            }
            
        }
}
    
    func onEnded(value:DragGesture.Value){
        if !self.interactions{return}
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            withAnimation(.linear) {
                if useSelected{
                    self.selected = -1
                }else{
                    self.choosen = -1
                }
            }
        }
}
}


struct CurveChart_Previews: PreviewProvider {
    static var previews: some View {
        CurveChart(data: [45,25,10,60,30,79].shuffled(),bg: .black)
            .background(Color.black)
    }
}
