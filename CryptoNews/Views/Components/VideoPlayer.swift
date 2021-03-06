//
//  VideoPlayer.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 28/08/2021.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SwiftUI
import XCDYouTubeKit
import youtube_ios_player_helper

enum VideoStates{
    case play
    case pause
    case idle
    case seekBack
    case seekForward
    case ready
}

enum VideoQuality{
    case high
    case low
}

protocol VideoDict{
    subscript (_ vid:String) -> AVAsset? {get set}
}

struct VideoCache:VideoDict{
    let cache:NSCache<NSString,AVAsset> = {
        let cache = NSCache<NSString,AVAsset>()
        cache.countLimit = 100;
        cache.totalCostLimit = 1024 * 1024 * 200
        return cache
    }()
    
    subscript(vid: String) -> AVAsset? {
        get{
            guard let asset = self.cache.object(forKey: vid as NSString) else{return nil}
            return asset as AVAsset
        }
        
        set{
            guard let asset = newValue else {return}
            self.cache.setObject(asset, forKey: vid as NSString)
        }
    }
    
    static var shared:VideoCache = .init()
}


class AVPlayerObj:ObservableObject{
    @Published var videoState:VideoStates = .idle{
        didSet{
            self.updateVideoState(state: self.videoState)
        }
    }
    @Published var quality:VideoQuality = .high
    @Published var player:AVPlayer? = nil
    @Published var video_url:String?{
        didSet{
            self.initPlayer()
        }
    }
    @Published var video_id:String?{
        didSet{
            self.getVideo()
        }
    }

    func updateVideoState(state:VideoStates){
        switch(state){
            case .play:
                self.play()
            case .pause:
                self.pause()
            case .seekBack, .seekForward:
                self.seek()
            default:
                print("default !")
                break
        }
    }
    
    func initPlayer(){
        guard let vid_url = self.video_url, let url = URL(string: vid_url) else {return}
        var asset:AVAsset? = nil
        if let _asset = VideoCache.shared[vid_url]{
            asset = _asset
        }else{
            asset = AVAsset(url: url)
            VideoCache.shared[vid_url] = asset
        }
        DispatchQueue.main.async {
            guard let asset = asset else {return}
            self.player = .init(playerItem: .init(asset: asset))
            print("Got the Video from Firebase!")

        }
        
       
    }
    
    func getVideo(){
        guard let id = self.video_id, self.player == nil else {return}
        if let asset = VideoCache.shared[id]{
            print("Got the URL from videoCache !")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                self.player = .init(playerItem: .init(asset: asset))
                self.videoState = .ready
            }
        }else{
            XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, err) in
                guard let video = video, let streamURL = self.quality == .high ? video.streamURL : video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else {return}
                DispatchQueue.main.async {
                    let asset = AVAsset(url: streamURL)
                    VideoCache.shared[streamURL.absoluteString] = asset
                    self.player = .init(playerItem: .init(asset: asset))
                    self.videoState = .ready
                }
            }
        }
    }
    
    func seek(handler:((VideoStates) -> Void)? = nil){
         if self.player != nil, let seconds = self.player?.currentTime().seconds{
            let curr_time = Float64(seconds)
            let diff = Float64(self.videoState == .seekBack ? -10 : 10)
            self.player!.seek(to: CMTimeMakeWithSeconds(curr_time + diff, preferredTimescale: 1),toleranceBefore: .zero,toleranceAfter: .zero)
            self.videoState = .play
        }
    }
    
    func play(){
        self.player?.play()
    }
    
    func pause(){
        self.player?.pause()
    }
}


struct SimpleVideoPlayer: UIViewControllerRepresentable{
    
    @Binding var playerState:VideoStates
    var player:AVPlayer
    var frame:CGRect
    init(player:AVPlayer,videoState:Binding<VideoStates>,frame:CGRect){
        self.player = player
        self._playerState = videoState
        self.frame = frame
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerView = AVPlayerViewController()
        playerView.showsPlaybackControls = false
        playerView.player = self.player
        playerView.view.frame = self.frame
        playerView.videoGravity = .resizeAspect
        return playerView
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        switch(self.playerState){
            case .play:
                self.player.play()
            case .pause:
                self.player.pause()
            default:
                break
        }
    }
    
    
}

struct YoutubePlayer:UIViewRepresentable{
    
    var size:CGSize = .zero
    var videoID:String
    @Binding var playerState:YTPlayerState
    var player:YTPlayerView
    init(size:CGSize,videoID:String,playerState:Binding<YTPlayerState>){
        self.size = size
        self.videoID = videoID
        self._playerState = playerState
        self.player = YTPlayerView(frame: .init(origin: .zero, size: size))
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    func makeUIView(context: Context) -> YTPlayerView {
        self.player.load(withVideoId: self.videoID)
        self.player.sizeThatFits(self.size)
        player.delegate = context.coordinator
        return self.player
    }
    
    func avplayerView(view parentView:UIView? = nil){
        if let view = parentView{
            if view.subviews.isEmpty{
                return
            }else{
                view.subviews.forEach { view in
                    print("DEBUG : ",view)
                    self.avplayerView(view: view)
                }
            }
        }
        return
    }
    
    
    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        uiView.playerState { state, err in
            if self.playerState == .playing && state != .playing{
                uiView.playVideo()
            }else if self.playerState == .paused &&  state == .playing{
                uiView.pauseVideo()
            }
        }
    }
    
    
    class Coordinator:NSObject,YTPlayerViewDelegate{
        var parent:YoutubePlayer
        
        init(parent:YoutubePlayer){
            self.parent = parent
        }

        func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            if self.parent.playerState != state{
                self.parent.playerState = state
            }
        }
    }
    
}
