//
//  DiamondChart.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 04/09/2021.
//

import SwiftUI

struct BaseDiamond:View{
    var size:CGSize
    var color:Color
    init(size:CGSize,color:Color = .gray.opacity(0.5)){
        self.size = size
        self.color = color
    }
    
    var body: some View{
        GeometryReader{g in
            let w = g.size.width
            let h = g.size.height
            let length = min(w,h)
            let middle = length * 0.5
            
            Path{path in
                path.move(to: .init(x: 0, y: middle))
                path.addLine(to: .init(x: middle, y: 0))
                path.addLine(to: .init(x: length, y: middle))
                path.addLine(to: .init(x: middle, y: length))
                path.addLine(to: .init(x: 0, y: middle))
            }
            .stroke(self.color, style: .init(lineWidth: 2.5, lineCap: .round))
            .frame(width: size.width, height: size.height, alignment: .center)
        }.padding(10)
        
        .frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
}


struct VariableDiamond:View{
    var size:CGSize
    var color:Color
    var points:[Float]
    init(size:CGSize,points:[Float],color:Color = .gray.opacity(0.5)){
        self.size = size
        self.points = points
        self.color = color
    }
    
    var corner_points:[Float]{
        return points.count > 4 ? Array(points[...3]) : self.points
    }
    
    
    func computeCornerPoints(offset idx:Int , element point:CGPoint,length:CGFloat) -> CGPoint{
        let value = CGFloat(self.corner_points[idx > 3 ? idx%4 : idx])
        var corner = point
        let middle = length * 0.5
        let negative_val = (1 - value) * middle
        
        if idx%2 == 0{
            if corner.x == length{
                corner.x -= negative_val
            }else if corner.x == 0{
                corner.x = negative_val
            }
            
        }else if idx%2 == 1{
            if corner.y == length{
                corner.y -= negative_val
            }else if corner.y == 0{
                corner.y = negative_val
            }
        }
//        print("Corner Pt. : ",corner)
    
        return corner
    }
    
    var body: some View{
        GeometryReader{g in
            let w = g.size.width
            let h = g.size.height
            let length = min(w,h)
            let middle = length * 0.5
            let corners:[CGPoint] = Array([.init(x: 0, y: middle),.init(x: middle, y: 0),.init(x: length, y: middle),.init(x: middle, y: length),.init(x: 0, y: middle)].enumerated()).compactMap({self.computeCornerPoints(offset: $0.offset, element: $0.element,length: length)})
            
            Path{path in
                path.addLines(corners)
            }
            .stroke(self.color, style: .init(lineWidth: 2.5, lineCap: .round))
            .frame(width: size.width, height: size.height, alignment: .center)
        }.padding(10)
        .frame(width: size.width, height: size.height, alignment: .bottom)
    }
}

struct DiamondAxis:View{
    var size:CGSize
    var color:Color
    init(size:CGSize,color:Color = .gray.opacity(0.5)){
        self.size = size
        self.color = color
    }
    
    var body: some View{
        GeometryReader{g in
            let w = g.size.width
            let h = g.size.height
            let length = min(w,h)
            let middle = length * 0.5
            
            
            ZStack(alignment: .center){
                Path{path in
                    path.move(to: .init(x: middle, y: length))
                    path.addLine(to: .init(x: middle, y: 0))
                }
                .stroke(self.color, style: .init(lineWidth: 2.5, lineCap: .round))
                .frame(width: size.width, height: size.height, alignment: .center)
                Path{path in
                    path.move(to: .init(x: 0, y: middle))
                    path.addLine(to: .init(x: length, y: middle))
                }
                .stroke(self.color, style: .init(lineWidth: 2.5, lineCap: .round))
                .frame(width: size.width, height: size.height, alignment: .center)
            }
            
        }.padding(10)
        .frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
}


struct DiamondChart: View {
    var size:CGSize
    var percent:[String:Float]
    init(size:CGSize = CGSize(width: totalWidth - 20, height: totalWidth - 20),percent:[String:Float]){
        self.size = size
        self.percent = percent
    }
    
    var keys:[String]{
        return Array(self.percent.keys)
    }
    
    
    var values:[Float]{
        return self.keys.compactMap({self.percent[$0] ?? nil })
    }
    
    var chartInfo:some View{
        let min = size.width
        return VStack(alignment: .center, spacing: 10){
            MainText(content: keys.last ?? "Last", fontSize: 10, color: .white)
            Spacer()
            HStack(alignment: .center, spacing: 10){
                MainText(content: keys.first ?? "First" , fontSize: 10, color: .white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: min * 0.40)
                Spacer()
                MainText(content: keys[2] , fontSize: 10, color: .white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: min * 0.40)
            }
            Spacer()
            MainText(content: keys[1], fontSize: 10, color: .white)
        }
//        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .zIndex(0)
    }
    
    var body: some View {
        let size:CGSize = .init(width: size.width * 0.9, height: size.height * 0.9)
        ZStack(alignment: .center){
            self.chartInfo
            BaseDiamond(size: size)
            BaseDiamond(size: .init(width: size.width * 0.5, height: size.height * 0.5))
            DiamondAxis(size: size)
            VariableDiamond(size: size, points: self.values.reversed(),color: .blue)
        }
    }
}

struct DiamondChart_Previews: PreviewProvider {
    static var previews: some View {
        DiamondChart(percent: ["Value 1":0.65,"value 2" : 0.85,"value 3" : 0.5,"value 4" : 0.3])
    }
}
