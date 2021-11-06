//
//  ProfileView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import SwiftUI

class ProfileData:Codable{
    var firstName:String?
    var middleName:String?
    var lastName:String?
    var userName:String?
    var email:String?
    var img:String?
    var info_coins:Float?
    var location:String?
    var dob:String?
    var followers:Int
    init(
        firstName:String?,
        middleName:String?,
        lastName:String?,
        userName:String?,
        email:String?,
        img:String? = nil,
        info_coins:Float?,
        location:String? = "Dubai, UAE",
        dob:String? = "11 March 1998",
        followers:Int = 1000
    ){
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.userName = userName
        self.email = email
        self.img = img
        self.info_coins = info_coins
        self.location = location
        self.dob = dob
        self.followers = followers
    }
    
    var name:String{
        return [self.firstName,self.middleName,self.lastName].reduce("", {$0 + " " + ($1 ?? "")})
    }
    
    var userInfoKeys:[String]{
        return ["Followers","Following","i.nfo Rank","Location","Date of Birth"]
    }
    
    var userInfo:[String:String]{
        var data:[String:String] = [:]
        data["Followers"] = String(self.followers)
        data["Following"] = String(230)
        data["i.nfo Rank"] = String(3423)
        data["Location"] = self.location ?? "NYC"
        data["Date of Birth"] = self.dob ?? Date().stringDate()
        return data
    }
    
    
    static var test:ProfileData = .init(firstName: "Krishna", middleName: "K", lastName: "Venkatramani", userName: "thecryptoknight", email: "thecryptoknight@gmail.com", info_coins: 100)
}

struct ProfileView: View {
    @EnvironmentObject var context:ContextData
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(width: totalWidth) { w in
                self.userInfo(w: w)
                    .padding(.top,50)
                self.userAccount(w:w)
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
    }
}

extension ProfileView{
    
    var user:ProfileData{
        return self.context.user
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
            MainSubHeading(heading: self.user.name , subHeading: self.user.userName ?? "username123", headingSize: 15, subHeadingSize: 13, headingFont: .normal, subHeadingFont: .normal, headColor: .white, subHeadColor: .gray, alignment: .center)
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
        VStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: "NFO", subHeading: self.user.info_coins?.ToDecimals() ?? "", headingSize: 15, subHeadingSize: 45, alignment: .center)
            InfoGrid(info: self.SocialMetricsKeys,width: w, viewPopulator: self.SocialinfoGridEl(key:))
        }.basicCard(size: .init(width: w, height: 0))
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
