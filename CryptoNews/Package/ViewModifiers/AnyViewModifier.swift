//
//  AnyViewModifier.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 07/03/2022.
//

import SwiftUI

public extension View{
    func anyViewWrapper() -> AnyView{
        AnyView(self)
    }
}

