//
//  ProfileUser.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/03/2022.
//

import SwiftUI

struct ProfileUser: View {
    @EnvironmentObject var context:ContextData
    var width:CGFloat
    @State var showFeatures:Bool = false
    @State var showRequirement:Bool = false
    
    init(width:CGFloat = totalWidth - 30){
        self.width = width
    }
    
    var userClass:ProfileClassType{
        self.context.user.user?.profileClass?.profileClassType ?? .silver
    }
    
    var userClassIdx:CGFloat{
        return CGFloat(self.classTypes.lastIndex(of: .silver) ?? 3)
    }
    
    var classTypes:[ProfileClassType]{
        return [.novice,.iron,.bronze,.silver,.gold,.platinium]
    }
    
    func unitWidthCalculator(w inner_w:CGFloat) -> CGFloat{
        inner_w/CGFloat(self.classTypes.count - 1)
    }
    
    func classView(w width:CGFloat) -> some View{
        let count = self.classTypes.count
        
        return HStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.classTypes.enumerated()), id:\.offset) { _type in
                let type = _type.element
                let idx = _type.offset
                let bgColor:Color = CGFloat(idx) <= self.userClassIdx ? .white : .black
                let color:Color = CGFloat(idx) <= self.userClassIdx ? .black : .white
                let selected = CGFloat(idx) == self.userClassIdx
                
                SystemButton(b_name: type.emojiConverter().rawValue, color: color, haveBG: true, size: .init(width: 15, height: 15), bgcolor: bgColor,alignment: .vertical) {}
                .frame(width: width/CGFloat(count), alignment: .center)
                .scaleEffect(selected ? 1.125 : 1)
                
            }
        }
        .frame(width: width, alignment: .center)
    }
    

    func lineColorView(w inner_w:CGFloat) -> some View{
        let unitWidth = self.unitWidthCalculator(w: inner_w)
        let highlightWidth = self.unitWidthCalculator(w: inner_w - unitWidth)
        return ZStack(alignment: .leading) {
            BlurView.thinLightBlur
                .frame(width: inner_w - unitWidth, height: 3, alignment: .center)
                .clipContent(clipping: .roundClipping)
            Color.AppBGColor
                .frame(width: highlightWidth * self.userClassIdx, height: 3, alignment: .center)
                .clipContent(clipping: .roundClipping)
        }
    }
    
    func classNameView(w inner_w:CGFloat) -> some View{
        let unitWidth = self.unitWidthCalculator(w: inner_w)
        return HStack(alignment: .center, spacing: 0) {
            ForEach(self.classTypes, id: \.rawValue) { type in
                MainText(content: type.rawValue.capitalized, fontSize: 12, color: .white, fontWeight: .medium)
                    .frame(maxWidth:unitWidth,alignment: .center)
            }
        }
    }
    
    func chartLineIndicatorView(w inner_w:CGFloat) -> some View{
        ZStack(alignment: .center) {
            self.lineColorView(w: inner_w)
            self.classView(w: inner_w)
        }
    }
    
    func bulletPoint(text mainText:String) ->  some View{
        HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "circle.fill",color: .white, haveBG: true, size: .init(width: 5, height: 5), bgcolor: .black, alignment: .vertical){}
            MainText(content: mainText, fontSize: 15, color: .white, fontWeight: .medium)
        }
    }
    
    func userFeaturesView(w:CGFloat) -> some View{
        Container(width: w, ignoreSides: true, orientation: .vertical, aligment: .leading, spacing: 10) { _ in
            self.bulletPoint(text: "Points to include")
            self.bulletPoint(text: "Points to include")
            self.bulletPoint(text: "Points to include")
        }
    }
    
    @ViewBuilder var userTypeInfo:some View{
        MainText(content: "You are a \(self.userClass.rawValue.capitalized) user", fontSize: 15, color: .white, fontWeight: .medium)
            .maskView {
                Color.mainBGColor
            }
    }
    
    @ViewBuilder func nextLevelDetails(w inner_w:CGFloat) ->  some View{
        if self.userClass != .platinium{
            MainText(content: "Skills required for next level", fontSize: 15, color: .white, fontWeight: .medium)
                .maskView {
                    Color.mainBGColor
                }
                .viewAdjacentButton(buttonName: "questionmark", orientation: .right,bgColor: .gray.opacity(0.5),hasBG: true, size: .init(width: 7.5, height: 7.5)) {
                    self.showRequirement.toggle()
                }

            if self.showRequirement{
                ForEach(Array(self.userClass.getRequirements().enumerated()),id: \.offset){ req in
                    MainText(content: req.element, fontSize: 15, color: .white, fontWeight: .medium)
                        .stylizeText(style: .bullet)
                        .animatedAppearance(idx: req.offset)
                }
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder func featureView(w inner_w:CGFloat) -> some View{
        if self.showFeatures{
            ForEach(Array(self.userClass.getFeatureSet().enumerated()),id:\.offset){ feature in
                MainText(content:feature.element, fontSize: 15, color: .white, fontWeight: .medium)
                    .stylizeText(style: .bullet)
                    .animatedAppearance(idx: feature.offset)
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder func innerView(w inner_w:CGFloat) -> some View{
        Container(width:inner_w){w in
            MainText(content: "You are a \(self.userClass.rawValue.capitalized) user", fontSize: 15, color: .white, fontWeight: .medium)
                .maskView {
                    Color.mainBGColor
                }
                .viewAdjacentButton(buttonName: "questionmark", orientation: .right,bgColor: .gray.opacity(0.5),hasBG: true, size: .init(width: 7.5, height: 7.5)) {
                    self.showFeatures.toggle()
                }
            
            self.featureView(w: inner_w)
            self.nextLevelDetails(w: inner_w)
        }
    }
    
    var body: some View {
        Container(heading: "User", headingColor: .white,headingDivider: false, width: self.width,ignoreSides: true,orientation: .vertical, aligment: .leading) { inner_w in
            self.chartLineIndicatorView(w: inner_w)
            self.classNameView(w: inner_w)
            self.innerView(w: inner_w)
        }
        .basicCard()
        .borderCard(gradient:Color.mainBGColor, clipping: .roundClipping)
    }
}

struct ProfileUser_Previews: PreviewProvider {
    
    @StateObject static var context:ContextData = .init()
    
    static var previews: some View {
        ProfileUser()
            .environmentObject(ProfileUser_Previews.context)
    }
}
