//
//  CrybPostMaiNView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/12/2021.
//

import SwiftUI

struct CrybPostMainView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var crybPostAPI:CrybPostAPI = .init()
    @State var width:CGFloat = totalWidth
    @State var ignoreSides:Bool = false
    
    init(width:CGFloat = .zero){
        if width != .zero{
            self._width = .init(initialValue: width)
        }
    }
    
    func onAppear(){
        if self.crybPostAPI.posts.isEmpty{
            self.crybPostAPI.loadPost()
        }
        
        if self.width == .zero && self.ignoreSides{
            self.ignoreSides.toggle()
        }
    }
    
    var posts:[CrybPostData]{
        return self.crybPostAPI.posts.isEmpty ? Array(repeating: CrybPostData.test, count: 10) : self.crybPostAPI.posts
    }
    
    
    @ViewBuilder func viewGen(data:Any) -> some View{
        if let postData = data as? CrybPostData{
            CrybPostCard(data: postData, cardWidth: self.width)
        }else{
            Color.clear.frame(width: self.width, height: 150, alignment: .center)
        }
    }
    
    func reload(){
        print("Reload!")
    }
    
    func mainBodyGen(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return LazyScrollView(data: self.posts, embedScrollView: false, viewGen: self.viewGen(data:))
            .onPreferenceChange(LazyScrollPreference.self) { reload in
            if reload{
                self.reload()
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading:"CrybPosts", width: totalWidth, ignoreSides: self.ignoreSides) { w in
                self.mainBodyGen(w: w)
            }
        }.padding(.top,30)
    }
}

struct CrybPostMaiNView_Previews: PreviewProvider {
    static var previews: some View {
        CrybPostMainView()
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
