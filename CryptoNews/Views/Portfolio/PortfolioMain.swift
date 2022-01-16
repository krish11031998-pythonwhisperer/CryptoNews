//
//  PortfolioMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct PortfolioMain: View {
    @EnvironmentObject var context:ContextData
    var assets:[CrybseAsset]
    var width:CGFloat
    init(assets:[CrybseAsset] = [],width:CGFloat = totalWidth - 20){
        self.assets = assets
        self.width = width
    }
    
    var body: some View {
        Container(heading: "Portfolio",headingColor: .black, width: self.width, verticalPadding: 15) { inner_w in
            ForEach(Array(self.assets.enumerated()), id: \.offset) { _asset in
                let asset = _asset.element
                PortfolioAsset(asset: asset, width: inner_w)
                    .environmentObject(self.context)
            }
        }.frame(width: self.width, alignment: .center)
            .background(mainLightBGView)
            .clipContent(clipping: .roundClipping)
    }
}


struct PortfolioAssetPreview:View{
    @StateObject var crybseAssetsAPI:CrybseAssetsAPI
    init(currencies: [String] = ["LTC","XRP","DOT"],uid:String){
        self._crybseAssetsAPI = .init(wrappedValue: .init(symbols:currencies,uid: uid))
    }
    
    func onAppear(){
        if self.crybseAssetsAPI.coinsData == nil{
            self.crybseAssetsAPI.getAssets()
        }
    }
    
    var body: some View{
        
        ZStack(alignment:.center){
            mainBGView.ignoresSafeArea()
            if let assets = self.crybseAssetsAPI.coinsData?.trackedAssets{
                Container(horizontalPadding: 7.5){ w in
                    PortfolioMain(assets: assets, width: w)
                }
            }else{
                ProgressView()
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            .ignoresSafeArea()
        .onAppear(perform: self.onAppear)
    }
    
    
}

struct PortfolioMain_Previews: PreviewProvider {
    
    @StateObject static var contextData:ContextData = ContextData()
    
    static var previews: some View {
        ScrollView {
            PortfolioAssetPreview(uid:"jV217MeUYnSMyznDQMBgoNHfMvH2")
                .environmentObject(PortfolioMain_Previews.contextData)
        }.ignoresSafeArea()
        
    }
}
