//
//  ViewController.swift
//  Carculator
//
//  Created by Leonardo Lombardi on 6/20/16.
//  Copyright © 2016 Uruzilla. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var displayDescription: UILabel!
    
    private var userIsAlreadyTyping = false
    
    private var displayValue: Double {
        get{
            return Double(display.text!)!

        }
        set {
            display.text = String(newValue)
            userIsAlreadyTyping = false
        }
    }

//    var savedProgram : CalculatorBrain.PropertyList?
    
//    @IBAction func save() {
//        savedProgram = brain.program
//    }
//    
//    @IBAction func restore() {
//        if savedProgram != nil{
//            brain.program = savedProgram!
//            displayValue = brain.result
//        }
//    }


    @IBAction func clearEverything(sender: UIButton) {
        display.text = "0"
        displayDescription.text = " "
        brain.clear()
    }

    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." && display.text!.rangeOfString(".") != nil{
            return
        }
        
        if userIsAlreadyTyping{
            display.text = display.text! + digit
        }else{
            display.text = digit
            userIsAlreadyTyping = true
        }
    }
    private var operandStack: Array<Double> = []
    
//    @IBAction private func enter() {
//        userIsAlreadyTyping = false
//        operandStack.append(Double(display.text!)!)
//        //operandStack.append(displayValue)
//        print("OperandStack = \(operandStack)")
//    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func operate(sender: UIButton) {
        if userIsAlreadyTyping{
            brain.setOperand(displayValue)
            userIsAlreadyTyping = false
        }
        
        if let operation = sender.currentTitle{
            brain.performOperation(operation)
            
        }
        displayValue = brain.result
        displayDescription.text = brain.description + trailingSymbol()
    }
    
    func trailingSymbol() -> String{
        return brain.isPartialResult ? " ..." : " ="
    }
}

