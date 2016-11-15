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
    
    private var userIsTypingNumber = false
    
    private var userWantsToSeeErrors = false //User define settings to be implemented a way to change this.
    
    private var displayValue: Double? {
        get{
            return Double(display.text!)

        }
        set {
            if newValue == nil {
                display.text = "0"
            } else {
                display.text = String(newValue!)
                let formater = NSNumberFormatter()
                formater.maximumFractionDigits = 6
                display.text = formater.stringFromNumber(newValue!)
            }
            userIsTypingNumber = false
            if !userWantsToSeeErrors && brain.operationError {
                display.text = "Error, invalid operation"
            }
        }
    }

    var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil{
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }


    @IBAction func clearEverything(sender: UIButton) {
        display.text = "0"
        displayDescription.text = " "
        brain.clear()
        brain.variableValues.removeAll()
    }

    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!

        
        if userIsTypingNumber {
            if digit == "." && display.text!.rangeOfString(".") != nil{
                return
            }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTypingNumber = true
        }
    }
    
    private var operandStack: Array<Double> = []
    
    @IBAction func undoLast(sender: UIButton) {
        if userIsTypingNumber {
            if display.text?.characters.count == 1 {
                display.text = "0"
            } else {
                display.text?.removeAtIndex(display.text!.endIndex.predecessor())
            }
        } else {
            brain.undoLast()
            brain.reCalculate()
            refreshDisplays()
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func operate(sender: UIButton) {
        if userIsTypingNumber {
            brain.setOperand(displayValue!)
            userIsTypingNumber = false
        }
        
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            
        }
        refreshDisplays()
    }
    
    func trailingSymbol() -> String{
        return brain.isBinaryOperationPending ? " ..." : " ="
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        let variable = String(sender.currentTitle!.characters.last!)
        brain.variableValues[variable] = displayValue!
        brain.undoLastIfANumberFunction()
        brain.reCalculate()
        refreshDisplays()
    }
    
    @IBAction func touchVariableDigit(sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        display.text = sender.currentTitle!
    }
    
    func refreshDisplays() {
        displayValue = brain.result
        displayDescription.text = brain.description + trailingSymbol()
    }
}

