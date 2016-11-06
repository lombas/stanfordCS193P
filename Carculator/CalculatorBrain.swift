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
    var description = ""
    var isBinaryOperationPending : Bool {
        // The result is not complete, it's missing the second operand of the binary operation
        get{
            return pendingBinaryOperation != nil
        }
    }
    var fractionDigitFormater: NSNumberFormatter {
        let formater = NSNumberFormatter()
        formater.maximumFractionDigits = 6
        formater.minimumFractionDigits = 0
        return formater
    }
    var shouldEqualsAddOperand = true
    
    func setOperand(operand:Double){
        acumulator = operand
        internalProgram.append(operand)
        if !isBinaryOperationPending {
            // if a operation is started and there is no pending operation, than it's a fresh new operation, so reset description
            description = fractionDigitFormater.stringFromNumber(acumulator)!
        }
    }
    
    private var operations: Dictionary<String, TypeOfOperation> = [
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
        "1/x" : TypeOfOperation.UnaryOperation({1/$0}),
        "rand" : TypeOfOperation.NumberCreator(Double(arc4random()) /  Double(UInt32.max))
    ]
    
    private enum TypeOfOperation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double)-> Double)
        case Equals
        case NumberCreator(Double)
    }
    
    func performOperation (symbol: String){
        internalProgram.append(symbol)
        
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value) :
                acumulator = value
                if isBinaryOperationPending {
                    description += " \(symbol)"
                    shouldEqualsAddOperand = false
                } else {
                    description = " \(symbol)"
                }
            case .UnaryOperation(let function) :
                if isBinaryOperationPending {
                    description += "\(symbol)(\(fractionDigitFormater.stringFromNumber(acumulator)!))"
                    shouldEqualsAddOperand = false
                }else{
                    description = "\(symbol)(\(description))"
                }
                acumulator = function(acumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pendingBinaryOperation = PendingBinaryOperation(binaryFunction: function, firstOperand: acumulator)
                description += " \(symbol)"
            case .Equals:
                executePendingBinaryOperation()
            case .NumberCreator(let value):
                acumulator = value
                if isBinaryOperationPending {
                    description += " \(symbol)"
                    shouldEqualsAddOperand = false
                } else {
                    description = " \(symbol)"
                }
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if isBinaryOperationPending {
            if shouldEqualsAddOperand {
                description += " \(fractionDigitFormater.stringFromNumber(acumulator)!)"
            }
            acumulator = pendingBinaryOperation!.binaryFunction(pendingBinaryOperation!.firstOperand, acumulator)
            pendingBinaryOperation = nil
            shouldEqualsAddOperand = true
        }
    }
    
    private var pendingBinaryOperation : PendingBinaryOperation?
    
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
        pendingBinaryOperation = nil
        internalProgram.removeAll()
    }
    
    var result: Double{
        get{
            return acumulator
        }
    }
}
