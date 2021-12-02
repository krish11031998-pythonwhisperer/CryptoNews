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
    @State var width:CGFloat = .zero
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
    
    
    func mainBodyGen(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width == .zero{
                self.width = w
            }
        }
        
        let view = ScrollView(.vertical, showsIndicators: false) {
            ForEach(Array(self.posts.enumerated()), id:\.offset) { _post in
                CrybPostCard(data: _post.element, cardWidth: w)
                    .buttonify {
                        withAnimation(.easeInOut) {
                            self.context.selectedPost = _post.element
                        }
                    }
                    .padding(.vertical,10)
            }
        }
        
        return view
        
    }
    
    var body: some View {
        
        Container(width: totalWidth, ignoreSides: self.ignoreSides) { w in
            self.mainBodyGen(w: w)
        }
        
    }
}

struct CrybPostMaiNView_Previews: PreviewProvider {
    static var previews: some View {
        CrybPostMainView()
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
