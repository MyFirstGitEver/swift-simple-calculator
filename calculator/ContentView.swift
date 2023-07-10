//
//  ContentView.swift
//  calculator
//
//  Created by Gia Duc on 09/07/2023.
//

import SwiftUI

extension Button {
    func coloring(_ color : Color) -> some View {
        self
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(5)
        .font(.system(size: 20))
    }
}

enum SaveError {
    case cantSave
}

struct ContentView: View {
    @State private var buttonClicked = false
    @State private var showHistory = false
    @State private var expression = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                VStack(
                    alignment: .trailing,
                    spacing: 17) {
                        expressionScreen()
                        HStack(spacing: 15) {
                            utilityButton("folder.fill",{
                                showHistory = true
                            })
                            utilityButton("trash.fill", {
                                clearExpression()
                            })
                        }
                    }
                Spacer()
                rowNumbers(range: 1...3)
                rowNumbers(range: 4...6)
                rowNumbers(range: 7...9)
                signRow()
            }
            .navigationDestination(isPresented: $showHistory) {
                HistoryView()
            }
        }
    }
    
    func saveToDisk(newHistory : CalculationHistory) {
        let storage = UserDefaults.standard
        let history = storage.data(forKey: "history")
        
        if history == nil {
            let firstHistory = [newHistory]
            
            do {
                let data =  try Converter<[CalculationHistory]>.toData(firstHistory)
                
                storage.set(data, forKey: "history")
            } catch let error {
                print(error)
            }
            
            return
        }
        
        do {
            var dataArray = try Converter<[CalculationHistory]>.fromData(history!)
            
            dataArray.append(newHistory)
            
            let stored = try Converter<[CalculationHistory]>.toData(dataArray)
            
            storage.set(stored, forKey:  "history")
        } catch let error {
            print(error)
        }
    }
    
    func utilityButton(
        _ systemName : String,
        _ onClick :  @escaping  () -> ()) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: systemName)
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 18.0, height: 18.0)
        }.padding([.trailing], 15)
    }
    
    func signRow() -> some View{
        HStack(spacing: 30) {
            mainButton(
                content: "+",
                color: .green,
                onClick: {
                    addToExpression(" + ")
                })
            mainButton(
                content: "-",
                color: .red,
                onClick: {
                    addToExpression(" - ")
                })
            mainButton(
                content: "=",
                color: .yellow,
                onClick: {
                    let result = calculate(expression)
                    
                    if result == "NaN" {
                        expression = result
                        return // do nothing
                    }
                
                    saveToDisk(newHistory: CalculationHistory(
                        expression: expression,
                        result: result,
                        addTime: Date.now))
                    
                    expression = result
                })
        }
    }
    
    func expressionScreen() -> some View {
        Text(expression)
            .frame(
                maxWidth: .infinity,
                alignment: .leading)
            .padding(EdgeInsets(
                top: 70,
                leading: 10,
                bottom: 70,
                trailing: 10))
            .background(Rectangle().fill(.gray))
            .foregroundColor(.white)
            .font(.system(size: 33).weight(.semibold))
    }
    
    func rowNumbers(range : ClosedRange<Int>) -> some View {
        HStack(spacing : 30){
            ForEach(range, id: \.self) { clicked in
                mainButton(
                    content: String(clicked),
                    color: .black,
                    onClick: {
                        addToExpression(String(clicked))
                    })
            }
        }
    }
    
    func mainButton(
        content : String,
        color : Color,
        onClick : @escaping () -> ()) -> some View {
        Button(action: {
            onClick()
        }){
            Text(content)
                .contentShape(Rectangle())
                .frame(width: 80, height: 80)
        }.coloring(color)
    }
    
    func addToExpression(_ number : String) {
        if expression == "NaN" {
            expression = ""
        }
        expression.append(number)
    }
    
    func clearExpression() {
        expression = ""
    }
    
    func calculate(_ expression : String) -> String {
        let units = expression.components(separatedBy: " ")
        
        var shouldBeAlpha = true
        
        var result = 0
        var lastSign = "+"
        
        for unit in units {
            let number = Int(unit)
            
            if number == nil && shouldBeAlpha {
                return "NaN"
            }
            
            if !shouldBeAlpha {
                // valid and it is a sign
                lastSign = unit
            } // else valid and it is a number
            else if lastSign == "+" {
                result += number!
            }
            else {
                result -= number!
            }
            
            shouldBeAlpha = !shouldBeAlpha
        }
        
        return String(result)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
