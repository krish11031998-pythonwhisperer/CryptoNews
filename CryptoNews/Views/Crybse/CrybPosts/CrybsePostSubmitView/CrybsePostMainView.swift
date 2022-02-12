//
//  CrybsePostMainView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/02/2022.
//

import SwiftUI

class CrybsePostState:ObservableObject{
    @Published var page:Int = 1
    @Published var text = ""
    @Published var poll:CrybsePollData? = nil
    @Published var addPoll:Bool = false
    @Published var addPost:Bool = false
    
}

struct CrybsePostMainView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var postState:CrybsePostState = .init()
    @State var keyboardHeight:CGFloat = .zero
    @StateObject var notification:NotificationData = .init()

    var postForm:some View{
        CrybPostGen()
            .environmentObject(self.postState)
    }
    
    var pollForm:some View{
        AddPollPage()
            .environmentObject(self.postState)
    }
    
    func uploadButton(){
        print("Update the button")
        guard let uid = self.context.user.user?.uid, let username = self.context.user.user?.userName else {return}
        var postdata:CrybPostData = .test
        postdata.User = .init(uid: uid, userName: username)
        postdata.PostMessage =  self.postState.text
        if let safePoll = self.postState.poll{
            postdata.Poll = safePoll
        }
        CrybsePostAPI.shared.uploadPost(post: postdata,image: nil) { status in
            var heading = ""
            var message = ""
            if status{
                heading = "Upload Successful"
                message = "Your CrybsePost was uploaded successfully !"
            }else{
                heading = "Upload Unsuccessful"
                message = "Your CrybsePost was not uploaded successfully !"
            }
            setWithAnimation {
                self.notification.updateNotification(heading: heading, buttonText: "Done", showNotification: true, innerText: message)
            }
        }

    }
    
    var body: some View {
        TabView(selection: self.$postState.page) {
            self.postForm
                .tag(1)
            self.pollForm
                .tag(2)
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: self.postState.page)
        .keyboardAdaptiveValue(keyboardHeight: $keyboardHeight)
        .onChange(of: self.postState.addPost) { addPost in
            if addPost{
                self.uploadButton()
            }
        }
    }
}

struct CrybsePostMainView_Previews: PreviewProvider {
    
    @StateObject static var context = ContextData()
    
    static var previews: some View {
        CrybsePostMainView()
            .background(Color.mainBGColor.ignoresSafeArea())
            .environmentObject(CrybsePostMainView_Previews.context)
    }
}
