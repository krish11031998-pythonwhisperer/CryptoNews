//
//  UIManagerData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/09/2021.
//

import Foundation
import SwiftUI

enum Tabs:String{
    case home = "homekit"
    case feed = "message"
}

class ContextData:ObservableObject{
    @Published private var _tab:Tabs = .home
    @Published private var _selectedCurrency:AssetData? = nil
    @Published private var _selectedNews:AssetNewsData? = nil
    @Published private var _selectedSymbol:String? = nil
    @Published private var _addTxn:Bool = false
    
    
    
    var tab:Tabs{
        get{
            return self._tab
        }
        
        set{
            self._tab = newValue
        }
    }
    
    var selectedCurrency:AssetData?{
        get{
            return self._selectedCurrency
        }
        
        set{
            withAnimation(.easeInOut(duration: 0.5)) {
                self._selectedCurrency = newValue
            }
        }
    }
    
    var selectedSymbol:String?{
        get{
            return self._selectedSymbol
        }
        
        set{
            withAnimation(.easeInOut) {
                self._selectedSymbol = newValue
            }
        }
    }
    
    var selectedNews:AssetNewsData?{
        get{
            return self._selectedNews
        }
        
        set{
            withAnimation(.easeInOut(duration: 0.5)) {
                self._selectedNews = newValue
            }
        }
    }
    
    var addTxn:Bool{
        get{
            return _addTxn
        }
        set{
            withAnimation(.easeInOut) {
                self._addTxn = newValue
            }
        }
    }
}
