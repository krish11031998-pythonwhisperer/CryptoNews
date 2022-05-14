//
//  VideoSectionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/02/2022.
//

import SwiftUI

struct VideoSectionView: View {
    
    @StateObject var videoAPI:CrybseVideoAPI = .init(q: "cryptocurrency",limit:10)
    var width:CGFloat
    
    init(width:CGFloat){
        self.width = width
    }
    
    func onAppear(){
        if self.videoAPI.videos.isEmpty{
            self.videoAPI.getVideos()
        }
    }
    
    func videoBody(w:CGFloat) -> some View{
        ForEach(Array(self.videoAPI.videos.enumerated()),id:\.offset) { _video in
            let video = _video.element
//            VideoSectionCard(video: video, size: .init(width: w, height: totalHeight * 0.4))
            VideoCard(data: video,size: .init(width: w, height: totalHeight * 0.4))
        }
    }
    
    var body: some View {
        Container(heading: "Videos", width: self.width, ignoreSides:false, orientation: .horizontal, aligment: .topLeading, spacing: 15) { w in
            if !self.videoAPI.videos.isEmpty{
                self.videoBody(w: w)
            }else if self.videoAPI.loading{
                ProgressView().frame(width: w, height: totalHeight * 0.35, alignment: .center)
            }else if !self.videoAPI.loading && self.videoAPI.videos.isEmpty{
                MainText(content: "No Videos", fontSize: 15, color: .white, fontWeight: .medium)
            }
            
        }.onAppear(perform: self.onAppear)
    }
}

struct VideoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VideoSectionView(width: totalWidth)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
