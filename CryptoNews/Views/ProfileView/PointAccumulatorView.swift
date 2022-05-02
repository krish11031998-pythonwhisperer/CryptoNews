//
//  PointAccumulatorView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/03/2022.
//

import SwiftUI

struct PointAccumulatorView: View {
    @EnvironmentObject var context:ContextData
    var width:CGFloat
    
    init(w width:CGFloat = totalWidth){
        self.width = width
    }
    
    var userActivity:[String:Int]{
        return ["Reactions":50,"Likes":40,"Shares":40,"Polls":20]
    }
    
    @ViewBuilder func pointsView(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainTextSubHeading(heading: "\(self.userActivity.values.reduce(0, {$0 + $1}))", subHeading: "Points", headingSize: 35, subHeadingSize: 20, headColor: .white, subHeadColor: .white.opacity(0.5), orientation: .vertical, headingWeight: .medium, bodyWeight: .medium, spacing: 7.5, alignment: .center)
            Spacer()
            //Include Timer
            MainText(content: "Include Timer", fontSize: 15, color: .white, fontWeight: .medium)
        }
    }
    
    @ViewBuilder func pointsAccumulatedBreakdown(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.userActivity.keys.sorted().enumerated()), id: \.offset) { _key in
                let key = _key.element
                let idx = _key.offset
                if let value = self.userActivity[key]{
                    if idx != 0{
                        Spacer()
                    }
                    MainTextSubHeading(heading: key, subHeading: "\(value)", headingSize: 13, subHeadingSize: 20,headColor: .gray, subHeadColor: .white, orientation: .vertical, headingWeight: .semibold, bodyWeight: .medium,alignment: .center)
                }
            }
        }.frame(width: w, alignment: .center)
    }
    
    func Medals(medalClass:String) -> some View{
        var symb:String = ""
        switch (medalClass){
            case "first":
                symb = "pentagon"
                break
            case "second":
                symb = "octagon"
                break
            case "third":
                symb = "seal"
                break
            default:
                symb = "oval.portrait"
        }
        return SystemButton(b_name: symb,color: .white, size: .init(width: 25, height: 25)) {}
    }
    
    var multiplier:Float{
        return self.context.user.user?.profileClass?.cryptoMultiplier ?? 1
    }
    
    @ViewBuilder func pointsAccumulatedValueSummary(w width:CGFloat) ->  some View{
        Container(width:width) { w in
            HStack(alignment: .center, spacing: 10) {
                MainTextSubHeading(heading: "\(self.userActivity.values.reduce(0, {$0 + $1}))", subHeading: "Points", headingSize: 17.5, subHeadingSize: 10, headColor: .white, subHeadColor: .white.opacity(0.5), orientation: .vertical, headingWeight: .medium, bodyWeight: .medium, spacing: 7.5, alignment: .center)
                Spacer()
                MainText(content: "→", fontSize: 25, color: .gray, fontWeight: .bold)
                Spacer()
                MainTextSubHeading(heading: "#25", subHeading: "Daily User", headingSize: 17.5, subHeadingSize: 10,headColor: .white, subHeadColor: .gray, orientation: .vertical, headingWeight: .medium, bodyWeight: .medium)
                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    self.Medals(medalClass: "second")
                    MainText(content: "You", fontSize: 12, color: .white, fontWeight: .medium)
                }
                MainTextSubHeading(heading: "X", subHeading: self.multiplier.toString(), headingSize: 12, subHeadingSize: 17.5, headColor: .gray, subHeadColor: .white, orientation: .horizontal, headingWeight: .semibold, bodyWeight: .semibold, spacing: 5, alignment: .center)
            }
            MainText(content: "You're the 25th Most Active User", fontSize: 15, color: .white, fontWeight: .medium)
                .padding(.vertical)
        }
        .frame(width: width, alignment: .topLeading)
        .borderCard(gradient: Color.mainBGColor, clipping: .roundClipping)
    }
    
    var body: some View {
        Container(heading: "Points",headingDivider: false,width: self.width) { inner_w in
            self.pointsView(w: inner_w)
            self.pointsAccumulatedBreakdown(w: inner_w)
            self.pointsAccumulatedValueSummary(w: inner_w)
        }
        .basicCard()
    }
}

struct PointAccumulatorView_Previews: PreviewProvider {
    
    static var context:ContextData = .init()
    static var previews: some View {
        PointAccumulatorView()
            .environmentObject(PointAccumulatorView_Previews.context)
    }
}
