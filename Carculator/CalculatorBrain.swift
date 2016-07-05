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
    func setOperand(operand:Double){
        acumulator = operand
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
    
    var result: Double{
        get{
            return acumulator
        }
    }
}
