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
    @Published var asset_quantity:String  = "0"
    @Published var asset_spot_price:String = "0"
    @Published var subtotal:String = "0"
    @Published var total_inclusive_price:String = ""
    @Published var fee:String = "0"
    @Published var memo:String = ""
    @Published var uid:String  = ""
    @Published var added_Success:Bool? = nil
    
    
    
    static var empty:TxnFormDetails = .init()
    
    func parseToTransaction() -> Transaction{
        return .init(time: self.time, type: self.type, asset: self.asset, asset_quantity: self.asset_quantity.toFloat(), asset_spot_price: self.asset_spot_price.toFloat(), subtotal: self.subtotal.toFloat(), total_inclusive_price: self.total_inclusive_price.toFloat(), fee: self.fee.toFloat(), memo: self.memo, uid: self.uid)
    }
}


struct AddTransactionView:View {
    @EnvironmentObject var context:ContextData
    @State var txn:TxnFormDetails = .empty
    @State var type:TransactionType = .buy
    @State var entryType = "coin"
    @State var date:Date = Date()
    @State var showModal:ModalType = .none
    @State var isKeyboardOn:Bool = false
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
//        DispatchQueue.main.async {
            self.txn.asset_quantity = "0"
            self.context.addTxn = false
            
//        }
    }
    
    
    func convertToAED(_ val_str:String) -> String{
        let val = val_str.toFloat()
        return (val * 3.6).toString()
    }
    
    func updateTxnObject(){
        let subTotal = self.txn.asset_quantity.toFloat() * self.txn.asset_spot_price.toFloat()
        txn.fee = txn.fee == "" ? "0" : txn.fee
        txn.asset_spot_price = txn.asset_spot_price
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
    
    func buttonHandle(){
        if self.isKeyboardOn{
            hideKeyboard()
        }else{
            self.updateTxnObject()
            print("This is txn! : ",txn.parseToTransaction())
            TransactionAPI.shared.uploadTransaction(txn: txn.parseToTransaction()) { err in
                if let err_msg = err?.localizedDescription {
                    print("error : ",err_msg)
                    DispatchQueue.main.async {
                        self.txn.added_Success = false
                    }
                }else{
                    DispatchQueue.main.async {
                        self.txn.added_Success = true
                    }
                }
            }
        }
    }
    
    func fetchAssetData(sym:String?){
        guard let sym = sym else {return}
        let aapi = AssetAPI.shared(currency: sym)
        aapi.getAssetInfo { data in
            guard let data = data else {return}
            withAnimation(.easeInOut) {
                self.currentAsset = data
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
    
    var body: some View {
        ZStack(alignment:.bottom){
            Container(heading: self.currency ?? "Choose the currency", width: totalWidth,onClose: self.onClose) { w in
                VStack(alignment: .leading, spacing: 10) {
                    if self.currentAsset == nil{
                        CurrencyCardView(currency: $coin,width: w)
                    }
                    self.transactionType.frame(width: w, alignment: .leading)
                    self.txnValueField.frame(width: w, alignment: .center)
                    self.detailButtons.padding(.vertical,10)
                    self.numPad(w: w)
//                    Spacer()
                    TabButton(width: w, height: 50, title: self.isKeyboardOn ? "Update" : "Add Transaction", textColor: .white,action: self.buttonHandle)
                }
            }
            .padding(.vertical,50)
            .frame(height: totalHeight, alignment: .topLeading)
            
            if self.showModal == .date{
                self.datepickerView(w: totalWidth)
            }
            if self.showModal == .fee{
                self.feefieldView(w: totalWidth)
            }
            if self.showModal == .spot_price{
                self.spotPriceView(w: totalWidth)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onDisappear {
            if self.context.selectedSymbol != nil{
                self.context.selectedSymbol = nil
            }
            
            if self.isKeyboardOn{
                self.isKeyboardOn.toggle()
                hideKeyboard()
            }
            
            withAnimation(.easeInOut) {
                if  !self.context.showTab{
                    self.context.showTab.toggle()
                }
            }
            
        }
        .keyboardAdaptive(isKeyBoardOn: $isKeyboardOn)
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
        return self._currency ?? self.coin.s ?? "???"
    }
    
    
    func swipeCard(w:CGFloat,h:CGFloat = totalHeight * 0.3,heading:String = "NO Heading",buttonText:String = "Update",innerView: @escaping () -> AnyView,action: @escaping () -> Void) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold, style: .normal).padding(.bottom,20)
            innerView().padding(.vertical,5)
            Spacer()
            TabButton(width: w - 20, height: 50, title: buttonText, textColor: .white,action: action).padding(.bottom,15)
        }
        .padding(10)
        .frame(width: w,height: totalHeight * 0.3, alignment: .topLeading)
        .background(BlurView(style: .systemThickMaterialDark))
        .clipContent(clipping: .roundClipping)
        .transition(.slideInOut)
        .zIndex(2)
    }
    
    func numPad(w:CGFloat) -> some View{
        let numIconW = (w * 0.3) - 2.5
        var numPadSeq = Array(1...9).map({"\($0)"})
        numPadSeq.append(contentsOf: [".","0","Del"])
        let col = GridItem(.adaptive(minimum: numIconW, maximum: numIconW))
        let res = LazyVGrid(columns: [col], alignment: .center, spacing: 5) {
            ForEach(numPadSeq, id:\.self) { numVal in
                MainText(content: numVal, fontSize: 17, color: .white, fontWeight: .semibold)
                    .frame(width: numIconW, height: numIconW * 0.6, alignment: .center)
                    .buttonify {
                        print("Clicked : ",numVal)
                        if self.txn.asset_quantity == "0"{
                            self.txn.asset_quantity = numVal
                        }else{
                            self.txn.asset_quantity += numVal
                        }
                        
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
                .padding(.vertical,5)
        }
    }
    
    var transactionType:some View{
        HStack(alignment: .center, spacing: 5) {
            ForEach(self.types, id: \.rawValue) {type in
                MainText(content: type.rawValue.capitalized, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                    .blobify(color: self.type == type ? .green : .clear)
                    .buttonify {
                        withAnimation(.easeInOut) {
                            if self.type != type{
                                self.type = type
                            }
                        }
                    }
            }
        }
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
            let color = Color.white
            let size:CGFloat = self.entryType == "coin" ? self.value_size : 30
            
//            TextField("0",text: self.$txn.asset_quantity)
//                .coloredTextField(color: color,size: size,rightViewTxt: self.currency)
            HStack(alignment: .top, spacing: 5) {
                MainText(content: self.txn.asset_quantity, fontSize: 45, color: .white, fontWeight: .semibold)
                MainText(content: self.currency, fontSize: 13, color: .gray, fontWeight: .bold)
            }
            MainText(content: "\(convertToMoneyNumber(value: self.currentAsset?.price)) per coin", fontSize: 13, color: .white, fontWeight: .semibold, style: .normal)
        }.padding(.vertical,10)
    }
    
    
    
    var dateField:some View{
        var date = self.date.stringDate()
        if #available(iOS 15.0, *) {
            date = self.date.formatted(date: .abbreviated, time: .shortened)
        }
        return MainText(content: date, fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
            .blobify(color: .clear)
            .buttonify {
                self.updateModal(type: .date)
            }
    }
    
    var spotPriceView:some View{
        let spot_price = self.txn.asset_spot_price
        return MainText(content: "Spot Price : $\(spot_price == "" ? "0" : spot_price)", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
            .blobify(color: spot_price == "" ? .clear : .green)
            .buttonify {
                self.updateModal(type: .spot_price)
            }
    }
    
    
    func datepickerView(w:CGFloat) -> some View{
        self.swipeCard(w: w,heading: "Select Date") {
            return AnyView(DatePicker("", selection: $date, displayedComponents: [.date,.hourAndMinute])
                    .datePickerStyle(.automatic)
                    .labelsHidden()
            )
        } action: {
            self.updateModal(type: .none)
        }
    }
    
    var feeButton:some View{
        let fee_str = self.txn.fee
        return MainText(content: "Fee: $\(fee_str == "" ? "0" : fee_str)", fontSize: 15,color: .white, fontWeight: .semibold)
            .blobify(color: fee_str == "0" || fee_str == "" ? .clear : .green)
            .buttonify {
                self.updateModal(type: .fee)
            }
    }
    
    func feefieldView(w:CGFloat) -> some View{
        self.swipeCard(w: w, h: totalHeight * 0.5,heading: "Update Fees") {
            return AnyView(Group{
                TextField("0",text: self.$txn.fee)
                    .coloredTextField(color: .white,size: 30,rightViewTxt: "USD")
                    .keyboardType(.numberPad)
            })
        } action: {
            self.updateModal(type: .none)
        }
    }
    
    func spotPriceView(w:CGFloat) -> some View{
        self.swipeCard(w: w, h: totalHeight * 0.5, heading: "Update Spot Price") {
            return AnyView(TextField("0", text: self.$txn.asset_spot_price)
                    .coloredTextField(color: .white,size:30,rightViewTxt: "USD").keyboardType(.numberPad)
            )
        } action: {
            self.updateModal(type: .none)
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
            Color.mainBGColor
            AddTransactionView(currentAsset: asset, curr_str: self.currency)
        }.edgesIgnoringSafeArea(.top).frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
    }
    
    
}


struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTxnMainView()
            .edgesIgnoringSafeArea(.all)
    }
}
