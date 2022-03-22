//
//  ProfileView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var context:ContextData
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(width: totalWidth) { w in
                self.userInfo(w: w)
//                ProfileUser(width: w)
                ProfileUser(width: w)
                PointAccumulatorView(w: w)
                self.userActivity(w: w)
            }.padding(.vertical,50)
        }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
    }
}

extension ProfileView{
    
    var user:ProfileData{
        return self.context.user.user ?? .test
    }
    
    var trackedAssets:[CrybseAsset]{
        return self.context.userAssets.trackedAssets.sorted(by: {$0.Rank < $1.Rank})
    }
        
    @ViewBuilder func UserinfoGridEl (key:String) -> some View{
        if let value = self.user.userInfo[key]{
            MainSubHeading(heading: key, subHeading: value, headingSize: 12, subHeadingSize: 14,headColor: .white.opacity(0.75),subHeadColor: .white, alignment: .center)
        }else{
            Color.clear
        }
    }
    
    @ViewBuilder func imageBGView(_ w:CGFloat) -> AnyView{
        let h = totalHeight * 0.2
        let dp_h = w * 0.3
        ZStack(alignment: .center) {
            ImageView(img:UIImage(named: "bgImage"),width: w,height: h,contentMode: .fill,alignment: .topLeading)
            HStack(alignment: .center, spacing: 110) {
                Spacer()
                MainText(content: self.context.user.user?.location ?? "Dubai , UAE", fontSize: 15, color: .white, fontWeight: .medium)
                    .padding(7.5)
                    .basicCard()
            }
            .padding()
            .frame(width: w,height: h, alignment: .topLeading)
            
            ImageView(url: self.user.img, width: w * 0.3, height: dp_h, contentMode: .fill, alignment: .center, clipping: .circleClipping)
                .offset(y: h * 0.5)
        }.anyViewWrapper()
    }
    
    func userInfo(w:CGFloat) -> some View{
        VStack(alignment: .center, spacing: 15) {
            self.imageBGView(w)
                .padding(.bottom, w * 0.15)
            MainSubHeading(heading: self.user.name ?? "Name" , subHeading: self.user.userName ?? "username123", headingSize: 15, subHeadingSize: 13, headingFont: .normal, subHeadingFont: .normal, headColor: .white, subHeadColor: .white.opacity(0.75), alignment: .center)
            InfoGrid(info: self.user.userInfoKeys, width: w, viewPopulator: self.UserinfoGridEl(key:))
        }
        .padding(.bottom,20)
        .frame(width: w, alignment: .center)
        .basicCard()
        .borderCard(color: .white, clipping: .roundClipping)
    }
    
    var SocialMetricsKeys:[String]{
        return ["Likes","Shares","Comments"]
    }
    
    var SocialMetrics:[String:String]{
        var metrics:[String:String] = [:]
        self.SocialMetricsKeys.forEach { metric in
            metrics[metric] = "\(Int.random(in: 500...1000))"
        }
        return metrics
    }
    
    
    @ViewBuilder func SocialinfoGridEl (key:String) -> some View{
        if let value = self.SocialMetrics[key]{
            MainSubHeading(heading: key, subHeading: value, headingSize: 12, subHeadingSize: 20, alignment: .center)
        }else{
            Color.clear
        }
    }
    
    func userAccount(w:CGFloat) -> some View{
        Container(heading: "Mana", width: w, ignoreSides: false) { w in
            MainText(content: "\(self.user.info_coins?.ToDecimals() ?? "100") Tokens", fontSize: 25, color: .white, fontWeight: .semibold, style: .monospaced)
                .padding(.bottom,15)
            self.ManaSpendOptions(w: w)
        }
        .basicCard()
    }
    
    func ManaSpendOptions(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "bag.fill", b_content: "Shop", color: .black,size: .init(width: 15, height: 15), bgcolor: .white, alignment: .vertical) {
                print("Clicked Shopped")
            }
            .basicCard(size: .init(width: w * 0.5 - 10, height: 100))
            .buttonify {
                print("Clicked Button")
            }
            SystemButton(b_name: "newspaper.fill", b_content: "Subscribe", color: .black,size: .init(width: 15, height: 15), bgcolor: .white, alignment: .vertical) {
                print("Clicked Shopped")
            }
            .basicCard(size: .init(width: w * 0.5 - 10, height: 100))
            .buttonify {
                print("Clicked Button")
            }
        }.frame(width: w, alignment: .center)
    }
    
    var barData:[BarElement]{
        let arr = Array(repeating: Int(1), count: 7).map({_ in Float.random(in: 0...100)})
        let sum = arr.reduce(0, {$0 + $1})
//        print("arr : \(arr) and sum : \(sum)")
        return arr.map({BarElement(data: $0, axis_key: "", key: "", info_data: sum)})
        
    }
    
    var assetColorValuePairs:[Color:Float]{
        var colorValuePairs:[Color:Float] = [:]
        for asset in self.context.userAssets.trackedAssets{
            colorValuePairs[Color(hex: asset.Color)] = asset.Value
        }
        return colorValuePairs
    }
    
    func cryptoCurrencyInvestments(_ size:CGSize) -> some View{
        let h = size.height
        return Container(heading:"Portfolio Breakdown",width: size.width,ignoreSides: false, orientation: .vertical, alignment: .center){ w in
            DonutChart(diameter: h,valueColorPair: self.assetColorValuePairs)
                .padding(.vertical)
            ForEach(Array(self.trackedAssets.enumerated()),id:\.offset) { _trackedAsset in
                let asset = _trackedAsset.element
                QuickAssetInfoCard(asset: asset,showValue: true,value: (asset.Value/self.assetColorValuePairs.values.reduce(0, {$0 + $1})).ToDecimals() + "%", w: w)
                    .background(Color(hex: asset.Color).clipContent(clipping: .roundClipping))
            }
        }
    }
    
    func chartView(w:CGFloat) -> some View{
        let half_w = w * 0.5 - 5
        let el_h = half_w + 100
        let profileViewSize:CGSize = .init(width: w - 30, height: el_h - 30)
        let subscriberViewSize:CGSize = .init(width: half_w, height: el_h)
        let col = [GridItem.init(.flexible(), alignment: .center),GridItem.init(.flexible(), alignment: .center)]
        return LazyVGrid(columns: col, alignment: .center, spacing: 10) {
//            self.cryptoCurrencyInvestments(profileViewSize)
            CircleChart(percent: 10, header: "Subscriber Views", size: subscriberViewSize)
            BarChart(heading: "Weekly Views", bar_elements: self.barData, size: subscriberViewSize)
            CurveChart(data: self.barData.map({$0.data}), interactions: false, size: profileViewSize, header: "Profile Views", bg: .clear, lineColor: .white)
        }
    }
    
    
    func userActivity(w:CGFloat) -> some View{
        Container(heading: "Activity", width: w, ignoreSides: false) {w in
            InfoGrid(info: self.SocialMetricsKeys, width: w) { (key) in
                if let value = self.SocialMetrics[key]{
                    MainSubHeading(heading: key, subHeading: value, headingSize: 15, subHeadingSize: 30, headColor: .gray, subHeadColor: .white, alignment: .center)
                }else{
                    Color.clear
                }
            }
        }
//            self.chartView(w: w).padding(.top,15)        }
        .basicCard()
    }
    
}



struct ProfileView_Previews: PreviewProvider {
    @ObservedObject static var context:ContextData = .init()
    static var previews: some View {
        ProfileView()
            .environmentObject(ProfileView_Previews.context)
            .background(Color.mainBGColor)
            .edgesIgnoringSafeArea(.all)
    }
}
