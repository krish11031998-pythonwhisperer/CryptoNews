//
//  ContentView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomePage()
//        BarChart(heading:"Test",bar_elements: [BarElement(data: 75, axis_key: "🐻", key: "Very Bearish", info_data: 90892),BarElement(data: 15, axis_key: "😞", key: "Bearish", info_data: 908),BarElement(data: 150, axis_key: "😐", key: "Normal", info_data: 90098),BarElement(data: 190, axis_key: "☺️", key: "Bullish", info_data: 9098),BarElement(data: 50, axis_key: "🐂", key: "Very Bullish", info_data: 9098)], size: .init(width: totalWidth * 0.65, height: totalHeight * 0.5))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
