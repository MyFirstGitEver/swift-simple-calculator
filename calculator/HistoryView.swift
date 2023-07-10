//
//  HistoryView.swift
//  calculator
//
//  Created by Gia Duc on 09/07/2023.
//

import SwiftUI

struct CalculationHistory : Identifiable, Codable {
    var id : UUID
    
    var expression : String
    var result : String
    var addTime : Date
    
    init(expression: String, result: String, addTime: Date) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.addTime = addTime
    }
    
    init() {
        self.id = UUID()
        expression = ""
        result = ""
        addTime = Date.now
    }
}

struct HistoryView: View {
    @State private var showWarning = false
    @State private var history : [CalculationHistory] = []
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing : 15){
            Text("Calculation history")
                .font(.system(size: 23))
            Button("Click here to erase all from your history!") {
                showWarning = true
            }
            .foregroundColor(.red)
            .alert("Are you sure to delete all your data?", isPresented : $showWarning) {
                Button("OK", role : .destructive) {
                    let empty : [CalculationHistory] = []
                    
                    let storage = UserDefaults.standard
                    storage.set(empty, forKey: "history")
                    
                    dismiss()
                }
                Button("No, thanks", role: .cancel) {
                    
                }
            }
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(history) { data in
                        if data.expression == "" {
                            Text("Your history is empty :(")
                        }
                        else {
                            historyCalculationView(data)
                        }
                    }
                }
                .task {
                    let storage = UserDefaults.standard
                    
                    let stored = storage.data(forKey: "history")
                    
                    if stored == nil {
                        history.append(CalculationHistory())
                        return
                    }
                    
                    do {
                        history = try Converter<[CalculationHistory]>.fromData(stored!)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }.frame(maxHeight: .infinity,  alignment: .top)
    }
    
    func historyCalculationView(_ history : CalculationHistory) -> some View {
        VStack(spacing: 10) {
            Text(history.expression)
                .font(.system(size: 25))
            Text("Result: \(history.result)")
            Text("calculated at \(dateToString(history.addTime))")
            Divider().frame(height: 1).background(.gray)
        }
    }
    
    func dateToString(_ date : Date) -> String {
        let cal = Calendar.current
        
        let components = cal.dateComponents(
            [.year, .day, .month, .hour, .minute, .second], from: date)
        
        return "Ng. \(String(describing: components.day!)), th. \(components.month!), \(components.year!) - \(components.hour!):\(components.minute!):\(components.second!)"
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
