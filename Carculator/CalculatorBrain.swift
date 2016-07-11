//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Leonardo Lombardi on 6/22/16.
//  Copyright © 2016 Uruzilla. All rights reserved.
//

import Foundation

class CalculatorBrain  {
    
    private var acumulator = 0.0
    private var internalProgram = [AnyObject]()
    func setOperand(operand:Double){
        acumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,TypeOfOperation> = [
        "π": TypeOfOperation.Constant(M_PI),
        "℮": TypeOfOperation.Constant(M_E),
        "√": TypeOfOperation.UnaryOperation(sqrt),
        "cos" : TypeOfOperation.UnaryOperation(cos),
        "×" : TypeOfOperation.BinaryOperation({ $0 * $1 }),
        "÷" : TypeOfOperation.BinaryOperation({ $0 / $1 }),
        "+" : TypeOfOperation.BinaryOperation({ $0 + $1 }),
        "-" : TypeOfOperation.BinaryOperation({ $0 - $1 }),
        "=" : TypeOfOperation.Equals
    ]
    
    private enum TypeOfOperation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double)-> Double)
        case Equals
    }
    
    func performOperation (symbol: String){
        internalProgram.append(symbol)
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value) :
                acumulator = value
            case .UnaryOperation(let function) :
                acumulator = function(acumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: acumulator)
            case .Equals:
                executePendingBinaryOperation()

            }
        }
    }
    private func executePendingBinaryOperation(){
        if pending != nil{
            acumulator = pending!.binaryFunction(pending!.firstOperand, acumulator)
            pending = nil
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
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double{
        get{
            return acumulator
        }
    }
}
