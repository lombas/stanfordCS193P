//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Leonardo Lombardi on 6/22/16.
//  Copyright © 2016 Uruzilla. All rights reserved.
//

import Foundation

//TODO: The description display is getting cut out off screen when in landscape mode, and it's content aren't reseting after you finish a calculation and starting typing a new number.

class CalculatorBrain  {
    
    private var acumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var operandAlreadyAdded = false
    var description = ""
    var isPartialResult : Bool {
        get{
            return pending != nil
        }
    }
    
    func setOperand(operand:Double){
        acumulator = operand
        internalProgram.append(operand)
        if description == "" {
            description = String(acumulator)
        }
    }
    
    private var operations: Dictionary<String,TypeOfOperation> = [
        "π": TypeOfOperation.Constant(M_PI),
        "√": TypeOfOperation.UnaryOperation(sqrt),
        "∛": TypeOfOperation.UnaryOperation({ pow($0, 1/3)}),
        "sen" : TypeOfOperation.UnaryOperation(sin),
        "×" : TypeOfOperation.BinaryOperation( * ),
        "÷" : TypeOfOperation.BinaryOperation({ $0 / $1 }),
        "+" : TypeOfOperation.BinaryOperation({ $0 + $1 }),
        "-" : TypeOfOperation.BinaryOperation({ $0 - $1 }),
        "=" : TypeOfOperation.Equals,
        "x²" : TypeOfOperation.UnaryOperation({pow($0, 2)}),
        "x³" : TypeOfOperation.UnaryOperation({pow($0, 3)}),
        "1/x" : TypeOfOperation.UnaryOperation({1/$0})
    ]
    
    private enum TypeOfOperation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double)-> Double)
        case Equals
    }
    
    func cubeRoot(base:Double) -> Double{
        return pow(base, 3)
    }
    
    func performOperation (symbol: String){
        internalProgram.append(symbol)
        
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value) :
                acumulator = value
                description += " \(symbol)"
                operandAlreadyAdded = true
            case .UnaryOperation(let function) :
                if isPartialResult {
                    description += "\(symbol)(\(acumulator))"
                    operandAlreadyAdded = true
                }else{
                    description = "\(symbol)(\(description))"
                }

                acumulator = function(acumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                description = "\(description) \(symbol)"
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: acumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil{
            if !operandAlreadyAdded {
                description += " \(acumulator)"
            }
            acumulator = pending!.binaryFunction(pending!.firstOperand, acumulator)
            pending = nil
            operandAlreadyAdded = false
        }
    }
    
    private var pending : PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
    }
    typealias PropertyList = AnyObject
    var program:PropertyList{
        get{
            //arrays are value Types so this returns a copy of my private var
            return internalProgram
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let operation = op as? String{
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear(){
        acumulator = 0.0
        description = ""
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double{
        get{
            return acumulator
        }
    }
}
