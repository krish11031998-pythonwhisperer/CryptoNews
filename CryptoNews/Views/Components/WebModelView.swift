//
//  WebModelView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/09/2021.
//

import SwiftUI
import WebKit

func dummyFunction(){
    print("Dummy function")
}

struct CustomWebView:UIViewRepresentable{
    var url:URL? = nil
    @Binding var loading:Bool
    init(url:URL?,loading:Binding<Bool>? = nil){
        self.url = url
        self._loading = loading ?? .constant(false)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        guard let url = url else {return webView}
        webView.load(.init(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}


struct WebModelView: View {
    var url:URL?
//    @State var loading:Bool = false
    var close: () -> Void
    init(url:URL? = nil,close:(() -> Void)? = nil){
        self.url = url
        self.close = close ?? dummyFunction
    }
    
    func actionSheet() {
        guard let urlShare = url else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    var headerView:some View{
        HStack(alignment: .center, spacing: 0) {
            SystemButton(b_name: "xmark", action: self.close)
            Spacer()
            SystemButton(b_name: "square.and.arrow.up", action: self.actionSheet)
        }.padding()
            .padding(.top,15)
            .frame(width: totalWidth, height: totalHeight * 0.1, alignment: .leading)
            .background(Color.mainBGColor.opacity(0.5))
    }
    
    @ViewBuilder var mainView:some View{
        CustomWebView(url: self.url)
            .frame(width: totalWidth, height: totalHeight * 0.9, alignment: .center)
    }
    
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            self.headerView
            self.mainView
        }.edgesIgnoringSafeArea(.all).frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
    }
}

struct WebModelView_Previews: PreviewProvider {
    static var previews: some View {
        WebModelView(url: .init(string: "https://www.youtube.com/")).background(Color.black)
    }
}
