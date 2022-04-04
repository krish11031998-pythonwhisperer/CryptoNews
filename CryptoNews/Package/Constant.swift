//
//  Constant.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 04/03/2022.
//

import SwiftUI

public var totalWidth = UIScreen.main.bounds.width
public var halfTotalWidth = totalWidth * 0.5
public var AppWidth = totalWidth * 0.9
public var totalHeight = UIScreen.main.bounds.height

public struct CardSize{
    public static var slender = CGSize(width: totalWidth * 0.6, height: totalHeight * 0.5)
    public static var normal = CGSize(width: totalWidth * 0.5, height: totalHeight * 0.4)
    public static var medium = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.3)
    public static var small = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.2)
    public static var tiny = CGSize(width: totalWidth * 0.25, height: totalHeight * 0.2)
}

public func setWithAnimation(animation:Animation = .easeInOut,completion:@escaping () -> Void){
    DispatchQueue.main.async {
        withAnimation(animation) {
            completion()
        }
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
