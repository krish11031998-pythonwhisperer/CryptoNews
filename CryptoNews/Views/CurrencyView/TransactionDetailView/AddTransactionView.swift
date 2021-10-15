//
//  AddTransactionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/10/2021.
//

import SwiftUI

enum ModalType{
    case fee
    case date
    case none
}

struct AddTransactionView:View {
    @State var amount:Float = 0;
    @State var type:TransactionType = .none
    @State var entryType = "coin"
    @State var date:Date = Date()
    @State var fee:Float = 0.0
    @State var showModal:ModalType = .none
    var currency:String
    var currentAsset: AssetData
    
    var types:[TransactionType] = [.buy,.sell,.receive,.send]
    
    init(currentAsset:AssetData,curr_str:String){
        self.currentAsset = currentAsset
        self.currency = curr_str
    }
    
    
    func updateModal(type:ModalType){
        withAnimation(.easeInOut) {
            if self.showModal != type{
                self.showModal = type
            }
        }
    }
    var transactionType:some View{
        ScrollView(.horizontal, showsIndicators: false) {
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
    
    func swipeCard(w:CGFloat,h:CGFloat = totalHeight * 0.3,heading:String = "NO Heading",buttonText:String = "Update",innerView: @escaping () -> AnyView,action: @escaping () -> Void) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold, style: .normal).padding(.bottom,20)
            innerView()
            TabButton(width: w - 20, height: 50, title: buttonText, textColor: .white,action: action).padding(.bottom,15)
        }
        .padding(10)
        .frame(width: w,height: totalHeight * 0.3, alignment: .topLeading)
        .background(BlurView(style: .systemThickMaterialDark))
        .clipContent(clipping: .roundClipping)
        .transition(.slideInOut)
        .zIndex(2)
    }
    
    
    func datepickerView(w:CGFloat) -> some View{
        self.swipeCard(w: w,heading: "Select Date") {
            return AnyView(Group{
                DatePicker("", selection: $date, displayedComponents: [.date,.hourAndMinute])
                    .datePickerStyle(.automatic)
                    .labelsHidden()
                Spacer()
            })
        } action: {
            self.updateModal(type: .none)
        }
    }
    
    var feeButton:some View{
        MainText(content: "Fee: \(convertToMoneyNumber(value: fee))", fontSize: 15, color: .white)
            .blobify(color: self.fee == 0 ? .clear : .green)
            .buttonify {
                self.updateModal(type: .fee)
            }
    }
    
    func feefieldView(w:CGFloat) -> some View{
        self.swipeCard(w: w, h: totalHeight * 0.5,heading: "Update Fees") {
            return AnyView(Group{
                
            })
        } action: {
            self.updateModal(type: .none)
        }
    }
    
    var txnValueField:some View{
        VStack(alignment: .center, spacing: 10) {
            let color = self.amount == 0 ? Color.gray : Color.white
            let value = self.entryType == "coin" ? "\(Int(self.amount))" : convertToMoneyNumber(value: self.amount)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                MainText(content: value, fontSize: 50, color: color, fontWeight: .semibold, style: .monospaced)
                MainText(content: self.currency, fontSize: 13, color: .white, fontWeight: .bold, style: .monospaced)
            }.frame(alignment: .top)
            MainText(content: "\(convertToMoneyNumber(value: self.currentAsset.price)) per coin", fontSize: 13, color: .white, fontWeight: .semibold, style: .normal)
        }
    }
    
    var body: some View {
        ZStack(alignment:.bottom){
            HoverView(heading: self.currency) { w in
                VStack(alignment: .leading, spacing: 10) {
                    self.transactionType.frame(width: w, alignment: .center)
                    self.dateField
                    self.feeButton
                    Spacer().frame(height: totalHeight * 0.2, alignment: .center)
                    self.txnValueField.frame(width: w, alignment: .center)
                    Spacer()
                }
                .frame(width: w,height: totalHeight - 50, alignment: .topLeading)
                .zIndex(1)
            }
            if self.showModal == .date{
                self.datepickerView(w: totalWidth)
            }
            if self.showModal == .fee{
                self.feefieldView(w: totalWidth)
            }
        }
    }
}


struct AddTxnTester:View{
    @State var asset:AssetData? = nil
    
    func onAppear(){
        if self.asset == nil{
            let aapi = AssetAPI.shared(currency: "LTC")
            aapi.getAssetInfo { data in
                guard let safeData = data else {return}
                DispatchQueue.main.async {
                    self.asset = safeData
                }
            }
        }
    }
    
    var body: some View{
        ZStack(alignment: .center) {
            Color.mainBGColor
            if let asset = self.asset{
                AddTransactionView(currentAsset: asset, curr_str: asset.symbol ?? "BTC")
            }else{
                ProgressView()
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            .onAppear(perform: self.onAppear)
    }
    
    
}


struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
//        AddTransactionView()
        AddTxnTester()
            .padding(.vertical,20)
            .edgesIgnoringSafeArea(.all)
    }
}
