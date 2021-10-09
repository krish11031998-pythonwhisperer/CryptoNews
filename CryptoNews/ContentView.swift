//
//  ContentView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var context:ContextData
    var body: some View {
        HomePage()
            .environmentObject(self.context)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
