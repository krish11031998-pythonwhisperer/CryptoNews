//
//  CrybPostMaiNView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/12/2021.
//

import SwiftUI

struct CrybPostMainView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var crybPostAPI:CrybsePostAPI = .init()
    @State var width:CGFloat = .zero
    @State var ignoreSides:Bool = false
    
    init(width:CGFloat = .zero){
        if width != .zero{
            self._width = .init(initialValue: width)
        }
    }
    
    func onAppear(){
        if self.crybPostAPI.posts == nil{
            self.crybPostAPI.getPosts()
        }
        if self.width == .zero && self.ignoreSides{
            self.ignoreSides.toggle()
        }
    }
    
    var posts:[CrybPostData]{
        if let posts = self.crybPostAPI.posts{
            return posts
        }
        return Array(repeating: CrybPostData.test, count: 10)
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
    
    var mainBodyGen:some View{
        return LazyScrollView(data: self.posts, embedScrollView: false, viewGen: self.viewGen(data:))
            .onPreferenceChange(RefreshPreference.self) { reload in
            if reload{
                self.reload()
            }
        }
    }
    
    func loadView(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return ProgressView()
    }
        
    func addNewPost() -> AnyView{
        let view = SystemButton(b_name: "pencil.circle.fill", color: .white,haveBG: true, size: .init(width: 20, height: 20), bgcolor: .black, alignment: .vertical) {
            if !self.context.addPost{
                self.context.addPost.toggle()
            }
        }
        return AnyView(view)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading:"CrybPosts", width: totalWidth, ignoreSides: self.ignoreSides,rightView: self.addNewPost) { w in
                
                if self.width == .zero{
                    self.loadView(w: w)
                }else{
                    self.mainBodyGen
                }
            }
        }.padding(.top,30)
            .onAppear(perform: self.onAppear)
    }
}

struct CrybPostMainView_Previews: PreviewProvider {
    static var previews: some View {
        CrybPostMainView()
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
