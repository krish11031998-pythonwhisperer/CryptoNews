//
//  AddTransactionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/10/2021.
//

import SwiftUI
import UIKit

enum ModalType{
    case fee
    case date
    case spot_price
    case none
}

class TxnFormDetails:ObservableObject{
    @Published var time:String = ""
    @Published var type:String  = ""
    @Published var asset:String  = ""
    @Published var asset_quantity:String  = ""
    @Published var asset_spot_price:String = ""
    @Published var subtotal:String = ""
    @Published var total_inclusive_price:String = ""
    @Published var fee:String = ""
    @Published var memo:String = ""
    @Published var uid:String  = ""
    @Published var added_Success:Bool? = nil
    
    
    
    static var empty:TxnFormDetails = .init()
    
    func parseToTransaction() -> Transaction{
        return .init(time: self.time, type: self.type, asset: self.asset, asset_quantity: self.asset_quantity.toFloat(), asset_spot_price: self.asset_spot_price.toFloat(), subtotal: self.subtotal.toFloat(), total_inclusive_price: self.total_inclusive_price.toFloat(), fee: self.fee.toFloat(), memo: self.memo, uid: self.uid)
    }
    
    func updateTxnDetails(_ value:String,_ type:ModalType){
        if type == .fee{
            self.fee = value
        }else if type == .spot_price{
            self.asset_spot_price = value
        }else{
            self.asset_quantity = value
        }
    }
}


struct AddTransactionView:View {
    @EnvironmentObject var context:ContextData
    @Namespace var animation
    @StateObject var txn:TxnFormDetails = .empty
    @State var type:TransactionType = .buy
    @State var entryType = "coin"
    @State var date:Date = Date()
    @State var showModal:ModalType = .none
    @State var coin:CoinMarketData = .init()
    @State var _currency:String? = nil
    @State var currentAsset: AssetData? = nil
    
    var types:[TransactionType] = [.buy,.sell,.receive,.send]
    
    init(currentAsset:AssetData? = nil,
         curr_str:String? = nil
    ){
        if let asset = currentAsset{
            self.currentAsset = asset
            self.updateSpotPrice(asset: asset)
        }
        
        if let curr = curr_str{
            self.__currency = .init(wrappedValue: curr)
        }
        
    }
    
    
    func onClose(){
        if self.context.addTxn{
            withAnimation(.easeInOut) {
                self.context.addTxn.toggle()
            }
        }
        
        if self.context.tab == .txn{
            if self.context.prev_tab != .none{
                self.context.tab = self.context.prev_tab
                self.context.prev_tab = .none
            }else{
                self.context.tab = .home
            }
        }
    }
    
    func resetStates(){
        DispatchQueue.main.async {
            self.txn.asset_quantity = "0"
        }
    }
    
    
    func convertToAED(_ val_str:String) -> String{
        let val = val_str.toFloat()
        return (val * 3.6).toString()
    }
    
    func updateTxnObject(){
        let subTotal = self.txn.asset_quantity.toFloat() * self.txn.asset_spot_price.toFloat()
        txn.fee = txn.fee == "" ? "0" : txn.fee
        txn.asset_spot_price = txn.asset_spot_price == "" ? "0" : txn.asset_spot_price
        txn.asset = self.currency
        
        if #available(iOS 15.0, *){
            txn.time = self.date.ISO8601Format()
        }else {
            txn.time = self.date.stringDate()
        }
        txn.subtotal = subTotal.toString()
        txn.total_inclusive_price = (subTotal + txn.fee.toFloat()).toString()
        txn.type = self.type.rawValue
        txn.memo = "You \(type == .receive ? "received" : type == .buy ? "bought" : type == .sell ? "sold" : "sent") \(self.currency)"
        txn.uid = self.context.user.user?.uid ?? ""
    }
    
    func updateTxnAdditionState(state:Bool){
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.txn.added_Success = state
            }
        }
    }
    
    func buttonHandle(){
        self.updateTxnObject()
        print("This is txn! : ",txn.parseToTransaction())
        TransactionAPI.shared.uploadTransaction(txn: txn.parseToTransaction()) { err in
            if let err_msg = err?.localizedDescription {
                print("error : ",err_msg)
                self.updateTxnAdditionState(state: false)
            }else{
                self.updateTxnAdditionState(state: true)
            }
        }
    }
    
    func fetchAssetData(sym:String?){
        guard let sym = sym else {return}
        let aapi = AssetAPI.shared(currency: sym)
        aapi.getAssetInfo { data in
            guard let data = data else {return}
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.currentAsset = data
                }
            }
            
        }
    }
    
    func onAppear(){
        if let curr = self._currency , self.currentAsset == nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.fetchAssetData(sym: curr)
            }
        }
        
        withAnimation(.easeInOut) {
            if self.context.showTab{
                self.context.showTab.toggle()
            }
        }
    }
    
    func onDisappear(){
        if self.context.selectedSymbol != nil{
            self.context.selectedSymbol = nil
        }
        withAnimation(.easeInOut) {
            if  !self.context.showTab{
                self.context.showTab.toggle()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment:.bottom){
            Container(heading: self.currency, width: totalWidth,onClose: self.onClose) { w in
                VStack(alignment: .leading, spacing: 20) {
                    if self.currentAsset == nil{
                        CurrencyCardView(width: w)
                            .onPreferenceChange(CurrencySelectorPreference.self) { newValue in
                                if self.coin != newValue{
                                    self.coin = newValue
                                }
                            }
                    }
                    self.txnValueField.frame(width: w, alignment: .center)
                    self.transactionType(w:w)
                    self.detailButtons
                    if self.currentAsset != nil{
                        self.numPad(w: w)
                    }
                    
                    TabButton(width: w, height: 50, title: "Add Transaction", textColor: .white,action: self.buttonHandle)
                }
            }
            .padding(.vertical,50)
            .frame(height: totalHeight, alignment: .topLeading)
            
            if self.showModal != .none{
                self.choosenSideView(w: totalWidth)
            }
            
            if let state = self.txn.added_Success{
                self.swipeCard(w: totalWidth, heading: "Add Transaction", buttonText: "Close") {
                    return AnyView(MainText(content: "\(state ? "Success" : "Failed")", fontSize: 15, color: .white, fontWeight: .semibold))
                } action: {
                    withAnimation(.easeInOut) {
                        self.txn.added_Success = nil
                        self.resetStates()
                    }
                    
                }

            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onDisappear(perform: self.onDisappear)
        .onChange(of: self.coin.s, perform: self.fetchAssetData(sym:))
        .onChange(of: (self.currentAsset ?? .init()),perform: self.updateSpotPrice(asset:))
        .onChange(of: self.txn.added_Success) { newValue in
            if let value = newValue{
                print("The txn is : ",value)
            }
        }
    }
}

extension AddTransactionView{
    
    func updateSpotPrice(asset:AssetData){
        if let price = asset.price{
            self.txn.asset_spot_price = price.toString()
        }
    }
    
    
    var currency:String{
        return self._currency ?? self.coin.s ?? "Choose Currency"
    }
    
    
    func swipeCard(w:CGFloat,h:CGFloat = totalHeight * 0.3,heading:String = "NO Heading",buttonText:String = "Update",innerView: @escaping () -> AnyView,action: @escaping () -> Void) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold, style: .normal).padding(.bottom,20)
            innerView().padding(.vertical,5)
            Spacer()
            TabButton(width: w - 20, height: 50, title: buttonText, textColor: .white,action: action).padding(.bottom,15)
        }
        .padding(10)
        .frame(width: w, alignment: .topLeading)
        .aspectRatio(contentMode: .fit)
        .background(BlurView(style: .systemThickMaterialDark))
        .clipContent(clipping: .roundClipping)
        .transition(.slideInOut)
        .zIndex(2)
    }
    

    func numPadEventHandler(val:String,updateVal:((String) -> Void)? = nil){
        var valToUpdate = self.showModal == .fee ? self.txn.fee : self.showModal == .spot_price ? self.txn.asset_spot_price : self.txn.asset_quantity
        DispatchQueue.main.async {
            if val != "Del"{
                if valToUpdate == "0"{
                    valToUpdate = val
                }else{
                    valToUpdate += val
                }
            }else if valToUpdate.count > 0{
                valToUpdate.removeLast()
            }
            updateVal?(valToUpdate) ?? self.txn.updateTxnDetails(valToUpdate,self.showModal)
        }
        
    }
    
    
    
    func numPad(w:CGFloat) -> some View{
        let numIconW = (w * 0.3) - 2.5
        var numPadSeq = Array(1...9).map({"\($0)"})
        numPadSeq.append(contentsOf: [".","0","Del"])
        let col = GridItem(.adaptive(minimum: numIconW, maximum: numIconW))
        let res = LazyVGrid(columns: [col], alignment: .center, spacing: 10) {
            ForEach(numPadSeq, id:\.self) { numVal in
                MainText(content: numVal, fontSize: 17, color: .white, fontWeight: .semibold)
                    .frame(width: numIconW,height: numIconW * 0.75 ,alignment: .center)
                    .buttonify {
                        self.numPadEventHandler(val: numVal)
                    }
            }
        }

        return res
    }
    
    
    var detailButtons:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 5) {
                self.dateField
                self.feeButton
                self.spotPriceView
            }.padding(.horizontal,2.5)
                .padding(.vertical,10)
        }
    }
    
    func transactionType(w:CGFloat) -> some View{
        let el_width = w/4 - 2.5
        return HStack(alignment: .center, spacing: 5) {
            ForEach(Array(self.types.enumerated()), id: \.offset) {_type in
                let type = _type.element
                let idx = _type.offset
                let id = self.type == type
                
                
                MainText(content: type.rawValue.capitalized, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                    .padding(.vertical,15)
                    .frame(width: el_width, alignment: .center)
                    .background(
                        ZStack(alignment: .center){
                            if id{
                                Color.mainBGColor
                                    .frame(width: el_width, alignment: .center)
                                    .clipContent(clipping: .roundClipping)
                                    .matchedGeometryEffect(id: "box", in: self.animation,properties: .frame)
                                    .animation(.linear(duration: 0.175))
                            }else{
                                Color.clear
                            }
                        })
                    .buttonify {
                        withAnimation(.easeInOut) {
                            if self.type != type{
                                self.type = type
                            }
                        }
                    }
               
            }
        }.frame(width: w, alignment: .center)
        .background(BlurView(style: .regular).clipContent(clipping: .roundClipping))
    }
    
    
    func updateModal(type:ModalType){
        withAnimation(.easeInOut) {
            if self.showModal != type{
                self.showModal = type
            }
        }
    }
    
    var value_size:CGFloat{
        let amount_str = self.txn.asset_quantity
        if amount_str.count == 4{
            return 40
        }else if amount_str.count == 5{
            return 35
        }else if amount_str.count >= 6{
            return 30
        }else{
            return 45
        }
    }
    
    var txnValueField:some View{
        VStack(alignment: .center, spacing: 10) {
            let color:Color = self.txn.asset_quantity != "" ? .white : .gray
            let quantity:String = self.txn.asset_quantity != "" ? self.txn.asset_quantity : "0"
            HStack(alignment: .top, spacing: 5) {
                MainText(content: quantity, fontSize: self.value_size, color: color, fontWeight: .semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                MainText(content: self.currency == "Choose Currency" ? "XXX" : self.currency, fontSize: 13, color: .gray, fontWeight: .bold)
            }
            MainText(content: "\(convertToMoneyNumber(value: self.currentAsset?.price)) per coin", fontSize: 13, color: .white, fontWeight: .semibold, style: .normal)
        }.padding(.vertical,10)
        .frame(height: totalHeight * 0.15, alignment: .center)
    }
    
    
    
    var dateField:some View{
        var date = self.date.stringDate()
        if #available(iOS 15.0, *) {
            date = self.date.formatted(date: .abbreviated, time: .shortened)
        }
        return MainText(content: date, fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
            .blobify(color: AnyView(BlurView(style: .dark)))
            .buttonify {
                self.updateModal(type: .date)
            }
    }
    
    @ViewBuilder func choosenSideView(w:CGFloat) -> some View{
        if self.showModal == .spot_price{
            self.swipeCard(w: w, h: totalHeight * 0.5, heading: "Update Spot Price") {
                return AnyView(Group{
                    MainText(content: "$\(self.txn.asset_spot_price)", fontSize: 30, color: self.txn.fee != "0" ? .white : .gray, fontWeight: .semibold)
                    self.numPad(w: w)
                })
            } action: {
                self.updateModal(type: .none)
            }
        }else if self.showModal == .fee{
            self.swipeCard(w: w, h: totalHeight * 0.6,heading: "Update Fees") {
                return AnyView(Group{
                    MainText(content: "$\(self.txn.fee)", fontSize: 30, color: self.txn.fee != "0" ? .white : .gray, fontWeight: .semibold)
                    self.numPad(w: w)
                })
                            
            } action: {
                self.updateModal(type: .none)
            }
            
        }else{
            self.swipeCard(w: w,heading: "Select Date") {
                return AnyView(DatePicker("", selection: $date, displayedComponents: [.date,.hourAndMinute])
                                .datePickerStyle(.automatic)
                                .labelsHidden()
                )
            } action: {
                self.updateModal(type: .none)
            }
        }
    }
    
    
    var spotPriceView:some View{
        let spot_price = self.txn.asset_spot_price
        return MainText(content: "Spot Price : $\(spot_price == "" ? "0" : spot_price)", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
            .blobify(color: spot_price == "" ? AnyView(Color.clear) : AnyView(BlurView(style: .dark)))
            .buttonify {
                self.updateModal(type: .spot_price)
            }
    }

    
    var feeButton:some View{
        let fee_str = self.txn.fee
        return MainText(content: "Fee: $\(fee_str == "" ? "0" : fee_str)", fontSize: 15,color: .white, fontWeight: .semibold)
            .blobify(color: fee_str == "0" || fee_str == "" ? AnyView(Color.clear) : AnyView(BlurView(style: .dark)))
            .buttonify {
                self.updateModal(type: .fee)
            }
    }
    
}

struct AddTxnMainView:View{
    @State var asset:AssetData? = nil
    @State var coin:CoinMarketData = .init()
    var currency:String?
    init(asset:AssetData? = nil,currency:String? = nil){
        self.asset = asset
        self.currency = currency
    }
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if let curr = self.currency,self.asset == nil{
                let aapi = AssetAPI.shared(currency: curr)
                aapi.getAssetInfo { data in
                    guard let safeData = data else {return}
                    DispatchQueue.main.async {
                        self.asset = safeData
                    }
                }
            }
        }
    }
    
    
    var body: some View{
        ZStack(alignment: .center) {
//            mainBGView
            Color.mainBGColor
            AddTransactionView(currentAsset: asset, curr_str: self.currency)
        }.edgesIgnoringSafeArea(.top).frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
    }
    
    
}


struct AddTransactionView_Previews: PreviewProvider {
    
    @StateObject static var context:ContextData = .init()
    
    static var previews: some View {
        AddTransactionView(currentAsset: nil, curr_str: nil)
            .environmentObject(self.context)
            .background(Color.mainBGColor)
            .ignoresSafeArea()
    }
}
