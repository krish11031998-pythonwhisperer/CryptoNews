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
                    .padding(.top,50)
                self.userAccount(w:w)
                self.userActivity(w: w)
            }.padding(.bottom,100)
        }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
    }
}

extension ProfileView{
    
    var user:ProfileData{
        return self.context.user.user ?? .test
    }
    
    @ViewBuilder func UserinfoGridEl (key:String) -> some View{
        if let value = self.user.userInfo[key]{
            MainSubHeading(heading: key, subHeading: value, headingSize: 12, subHeadingSize: 14, alignment: .center)
        }else{
            Color.clear
        }
    }
    
    func userInfo(w:CGFloat) -> some View{
        VStack(alignment: .center, spacing: 15) {
            ImageView(url: self.user.img, width: w * 0.3, height: w * 0.3, contentMode: .fill, alignment: .center, clipping: .circleClipping)
            MainSubHeading(heading: self.user.name ?? "Name" , subHeading: self.user.userName ?? "username123", headingSize: 15, subHeadingSize: 13, headingFont: .normal, subHeadingFont: .normal, headColor: .white, subHeadColor: .gray, alignment: .center)
            InfoGrid(info: self.user.userInfoKeys, width: w, viewPopulator: self.UserinfoGridEl(key:))
        }.basicCard(size: .init(width: w, height: 0))
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
        }.basicCard(size: .init(width: w, height: 0))
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
        print("arr : \(arr) and sum : \(sum)")
        return arr.map({BarElement(data: $0, axis_key: "", key: "", info_data: sum)})
        
    }
    
    func chartView(w:CGFloat) -> some View{
        let half_w = w * 0.5 - 5
        let el_h = half_w + 100
        let col = [GridItem.init(.flexible(), alignment: .center),GridItem.init(.flexible(), alignment: .center)]
        return LazyVGrid(columns: col, alignment: .center, spacing: 10) {
            CircleChart(percent: 10, header: "Subscriber Views", size: .init(width: half_w, height: el_h))
            BarChart(heading: "Weekly Views", bar_elements: self.barData, size: .init(width: half_w, height: el_h))
            CurveChart(data: self.barData.map({$0.data}), interactions: false, size: .init(width: w - 30, height: el_h - 30), header: "Profile Views", bg: .clear, lineColor: .white)
                .basicCard(size: .init(width: w, height: el_h))
                .padding(.leading,half_w + 10)
            Color.clear.frame(width: half_w, height: el_h, alignment: .center)
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
            
            self.chartView(w: w).padding(.top,15)
            
        }
        .basicCard(size: .init(width: w, height: 0))
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
