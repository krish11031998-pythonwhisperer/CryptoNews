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
    
    
    var body: some View{
        GeometryReader{g in
            let w = g.size.width
            let h = g.size.height
            let length = min(w,h)
            let middle = length * 0.5
            let corners:[CGPoint] = [CGPoint(x: middle, y: length),CGPoint(x: 0, y: middle),CGPoint(x: middle, y: 0),CGPoint(x: length, y: middle)]
            
            Path{path in
                path.move(to: .init(x: middle, y: middle))
//                ForEach(Array(self.corner_points.enumerated()),id:\.offset){ _cp in
//                    let point = _cp.element
//                    let idx = _cp.offset
//                    var corner = corners[idx]
////                    corner.x = corner.x * CGFloat(idx%2 == 0 ? point : 1)
////                    corner.y = corner.y * CGFloat(idx%2 != 0 ? point : 1)
//                    path.addLine(to: corner)
//                }
//                path.addLine(to: .init(x: middle, y: 0))
//                path.addLine(to: .init(x: length, y: middle))
//                path.addLine(to: .init(x: middle, y: length))
//                path.addLine(to: .init(x: 0, y: middle))
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
    var percent:[Float]
    init(size:CGSize = CGSize(width: totalWidth - 20, height: totalWidth - 20),percent:[Float]){
        self.size = size
        self.percent = percent
    }
    
    var body: some View {
        ZStack(alignment: .center){
            BaseDiamond(size: size)
            BaseDiamond(size: .init(width: size.width * 0.5, height: size.height * 0.5))
            DiamondAxis(size: size)
        }
    }
}

struct DiamondChart_Previews: PreviewProvider {
    static var previews: some View {
        DiamondChart(percent: [0.65,0.85,0.5,0.3])
    }
}
