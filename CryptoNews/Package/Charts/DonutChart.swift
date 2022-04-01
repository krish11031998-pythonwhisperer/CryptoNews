//
//  DonutChart.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 20/03/2022.
//

import SwiftUI

struct DonutChart: View {
    
    var valueColorPair:[Color:Float] = [:]
    var selectedColor:Color? = nil
    var value:[Float]? = nil
    var diameter:CGFloat
    var lineWidth:CGFloat
    
    init(selectedColor:Color? = nil,diameter:CGFloat = totalWidth - 30,lineWidth:CGFloat = 20,valueColorPair:[Color:Float]? = nil,value:[Float]? = nil){
        self.selectedColor = selectedColor
        self.diameter = diameter
        self.lineWidth = lineWidth
        if let safeValueColorPair = valueColorPair{
            self.valueColorPair = safeValueColorPair
        }else if let safeValues = value{
            for value in safeValues {
                self.valueColorPair[Color.random] = value
            }
        }
    }
    
    
    
    var total:Float{
        var total:Float = .zero
        for value in self.valueColorPair.values{
            total += value
        }
        return total
    }
    
    var donutChartValue:[(key:Color,value:Float)]{
        return self.valueColorPair.sorted(by:{$0.value < $1.value})
    }
    
    func valueForIdx(_ idx:Int) -> Float{
        var count:Int = 0
        var factor:Float = 0
        while count < idx{
            factor += self.donutChartValue[count].value
            count += 1
        }
        return factor
    }

    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(Color.gray, lineWidth: self.lineWidth)
                .frame(width: self.diameter,height:self.diameter,alignment: .center)
            if let firstColor = self.donutChartValue.first?.key{
                let chartColor = self.selectedColor != nil ? self.selectedColor! == firstColor ? firstColor : .black : firstColor
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(chartColor, lineWidth: self.lineWidth)
                    .animation(.easeInOut)
                    .frame(width: self.diameter,height:self.diameter, alignment: .center)
            }
            if !self.donutChartValue.isEmpty && self.donutChartValue.count > 1{
                ForEach(Array(1..<self.donutChartValue.count),id:\.self){ idx in
                    let color = self.donutChartValue[idx].key
                    let value = CGFloat(1 - self.valueForIdx(idx)/total)
                    let chartColor = self.selectedColor != nil ? self.selectedColor! == color ? color : .black : color
                    
                    Circle()
                        .trim(from: 0, to: value)
                        .stroke(chartColor, lineWidth: self.lineWidth)
                        .animation(.easeInOut)
                        .frame(width: self.diameter,height:self.diameter, alignment: .center)
                    
                }
            }
        }
        .rotationEffect(.init(degrees: -90))
        .padding()
//        .padding()
//        .frame(width: self.diameter + 30,height: self.diameter + 30,alignment: .center)
    }
}

struct DonutChart_Previews: PreviewProvider {
    static var previews: some View {
        DonutChart(diameter:totalWidth * 0.75,lineWidth:22.5,valueColorPair: [Color.red:14,Color.blue:6,Color.black:8])
    }
}
