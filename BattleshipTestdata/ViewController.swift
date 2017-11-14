//
//  ViewController.swift
//  BattleshipTestdata
//
//  Created by STEFAN JOSTEN on 12.11.17.
//  Copyright © 2017 Stefan. All rights reserved.
//

import Cocoa

enum Direction: Int {
    case horizontal
    case vertical
}

enum Mode: Int {
    case array
    case matrix
    case human
    case shipcells
}

struct Vector {
    var x = 0
    var y = 0
}

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var rowSize: NSTextField!
    @IBOutlet weak var numberOfTrainingData: NSTextField!
    @IBOutlet var resultField: NSTextView!
    @IBOutlet weak var csvSeparator: NSTextField!
    @IBOutlet weak var numberOfShipsType1: NSTextField!
    @IBOutlet weak var numberOfShipsType2: NSTextField!
    @IBOutlet weak var numberOfShipsType3: NSTextField!
    @IBOutlet weak var numberOfShipsType4: NSTextField!
    @IBOutlet weak var shipSizeType1: NSTextField!
    @IBOutlet weak var shipSizeType2: NSTextField!
    @IBOutlet weak var shipSizeType3: NSTextField!
    @IBOutlet weak var shipSizeType4: NSTextField!
    
    var valueRowSize = 0
    var valueShipHitCount = 0
    var valueShipSize: [Int] = []
    var valueShips: [Int] = []
    var valueTrainingData = 0
    var valueCSVSeparator = " "
    var mode = Mode.matrix
    
    var battleFields: [[[Character]]] = []
    
    @IBAction func modeChanged(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            mode = .matrix
        } else if sender.selectedSegment == 1 {
            mode = .array
        } else if sender.selectedSegment == 2 {
            mode = .shipcells
        } else {
            mode = .human
        }
    
        if battleFields.count > 0 {
            resultField.string = battleFieldsToString()
        }
    }
    
    @IBAction func copyToClipboard(_ sender: Any) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultField.string, forType: .string)
    }
    
    
    @IBAction func generateCSV(_ sender: NSButton) {
        
        
        valueRowSize = covertNumeric(value: rowSize.cell!.title)
        valueShipSize.append(covertNumeric(value: shipSizeType1.cell!.title))
        valueShipSize.append(covertNumeric(value: shipSizeType2.cell!.title))
        valueShipSize.append(covertNumeric(value: shipSizeType3.cell!.title))
        valueShipSize.append(covertNumeric(value: shipSizeType4.cell!.title))
        valueShips.append(covertNumeric(value: numberOfShipsType1.cell!.title))
        valueShips.append(covertNumeric(value: numberOfShipsType2.cell!.title))
        valueShips.append(covertNumeric(value: numberOfShipsType3.cell!.title))
        valueShips.append(covertNumeric(value: numberOfShipsType4.cell!.title))
        valueTrainingData = covertNumeric(value: numberOfTrainingData.cell!.title)
        valueCSVSeparator = csvSeparator.cell!.title
      
        valueShipHitCount = valueShipSize[0] * valueShips[0] + valueShipSize[1] * valueShips[1] + valueShipSize[2] * valueShips[2] + valueShipSize[3] * valueShips[3]
        
        battleFields = []
        
        for _ in 0..<valueTrainingData {
            battleFields.append(generateBattlefield())
        }
        
        resultField.string = battleFieldsToString()
        
    }
    
    func battleFieldsToString() -> String {
        var csvText = ""
        var i = 0
        for battleField in battleFields {
            if mode == .human {
                csvText.append("Matrix " + String(i + 1) + "\n")
                i+=1
            }
            csvText.append(battleFieldToString(battleField: battleField))
        }
        return csvText
    }
    
    func battleFieldToString(battleField: [[Character]]) -> String {
        var matrixCSV = ""
        var hits = 0
        for i in 0..<valueRowSize {
            var row = battleField[i]
            var rowCSV = ""
            for j in 0..<valueRowSize {
                if mode == .shipcells {
                    if row[j] == "1" {
                        rowCSV.append(String(i * valueRowSize + j))
                        hits += 1
                        if hits < valueShipHitCount {
                            rowCSV.append(valueCSVSeparator)
                        }
                    }
                } else {
                    rowCSV.append(row[j])
                    if j < valueRowSize - 1 {
                        rowCSV.append(valueCSVSeparator)
                    }
                }
            }
            if mode != .array && mode != .shipcells {
                rowCSV.append("\n")
            } else if i < valueRowSize - 1 && mode != .shipcells {
                rowCSV.append(valueCSVSeparator)
            }
            matrixCSV.append(rowCSV)
        }
        if mode == .array || mode == .human || mode == .shipcells {
            matrixCSV.append("\n")
        }
        return matrixCSV
    }
    
    func generateBattlefield()-> [[Character]] {
        var matrix = [[Character]]()
        
        for _ in 0..<valueRowSize {
            var row = [Character]()
            for _ in 0..<valueRowSize {
                row.append("0")
            }
            matrix.append(row)
            
        }
      
        var bSuccess = false
        var vector = Vector(x: 0, y: 0)
        for i in 0..<4 {
            let valueShipsOfType = valueShips[i]
            let valueShipSizeOfType = valueShipSize[i]
            for _ in 0..<valueShipsOfType {
                bSuccess = false
                var shipCoord = [Vector]()
                while !bSuccess {
                var direction = Direction.horizontal
                if arc4random_uniform(2) == 1 {
                    direction = .vertical
                }
                shipCoord = [Vector]()
            
                // Horizontal or Vertical?
                if direction == .horizontal {
                    vector.x = Int(arc4random_uniform(UInt32(valueRowSize - valueShipSizeOfType)))
                    vector.y = Int(arc4random_uniform(UInt32(valueRowSize)))
                    shipCoord.append(vector)
                    for i in 1..<valueShipSizeOfType {
                        shipCoord.append(Vector(x: vector.x + i, y: vector.y))
                    }
                    bSuccess = checkRulesHorizontal(shipCoord: shipCoord, matrix: matrix)
                } else {
                    vector.x = Int(arc4random_uniform(UInt32(valueRowSize)))
                    vector.y = Int(arc4random_uniform(UInt32(valueRowSize - valueShipSizeOfType)))
                    shipCoord.append(vector)
                    for i in 1..<valueShipSizeOfType {
                        shipCoord.append(Vector(x: vector.x, y: vector.y + i))
                    }
                    bSuccess = checkRulesVertical(shipCoord: shipCoord, matrix: matrix)
                }
            }
            
            // fillMatrix
            for cell in shipCoord {
                matrix[cell.x][cell.y] = "1"
            }
            }
            
        }
        return matrix
    }
    

    
    func checkRulesHorizontal(shipCoord: [Vector], matrix: [[Character]]) -> Bool {
        let vectorFirst = shipCoord.first!
        let vectorLast = shipCoord.last!
        
        // left
        if vectorFirst.x > 0 {
            if matrix[vectorFirst.x - 1][vectorFirst.y] == "1" {
                return false
            }
        }
        
        // right
        if vectorLast.x < valueRowSize - 1 {
            if matrix[vectorLast.x + 1][vectorLast.y] == "1" {
                return false
            }
        }
        
        // upper corners
        if vectorFirst.y > 0 {
            // left upper corner
            if vectorFirst.x > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y - 1] == "1" {
                    return false
                }
            }
            // right upper corner
            if vectorLast.x < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y - 1] == "1" {
                    return false
                }
            }
        }
        
        // lower corners
        if vectorFirst.y < valueRowSize - 1 {
            // left lower corner
            if vectorFirst.x > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y + 1] == "1" {
                    return false
                }
            }
            // right lower corner
            if vectorLast.x < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y + 1] == "1" {
                    return false
                }
            }
        }
        
        // check rows
        for col in shipCoord {
            // identical row
            if matrix[col.x][col.y] == "1" {
                return false
            }
            // lower row
            if vectorFirst.y < valueRowSize - 1 {
                if matrix[col.x][col.y + 1] == "1" {
                    return false
                }
            }
            // upper row
            if vectorFirst.y > 0 {
                if matrix[col.x][col.y - 1] == "1" {
                    return false
                }
            }
        }
        if matrix[vectorFirst.x][vectorFirst.y] == "1" {
            return false
        }
        
        return true
    }

    func checkRulesVertical(shipCoord: [Vector], matrix: [[Character]]) -> Bool {
        let vectorFirst = shipCoord.first!
        let vectorLast = shipCoord.last!
        
        // top
        if vectorFirst.y > 0 {
            if matrix[vectorFirst.x][vectorFirst.y - 1] == "1" {
                return false
            }
        }
        
        // bottom
        if vectorLast.y < valueRowSize - 1 {
            if matrix[vectorLast.x][vectorLast.y + 1] == "1" {
                return false
            }
        }
        
        // left corners
        if vectorFirst.x > 0 {
            // left upper corner
            if vectorFirst.y > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y - 1] == "1" {
                    return false
                }
            }
            
            // left lower corner
            if vectorLast.y < valueRowSize - 1 {
                if matrix[vectorLast.x - 1][vectorLast.y + 1] == "1" {
                    return false
                }
            }
        }
        
        // right corners
        if vectorFirst.x < valueRowSize - 1 {
            // right upper corner
            if vectorFirst.y > 0 {
                if matrix[vectorFirst.x + 1][vectorFirst.y - 1] == "1" {
                    return false
                }
            }
            
            // right lower corner
            if vectorLast.y < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y + 1] == "1" {
                    return false
                }
            }
        }
        
        // check colums
        for col in shipCoord {
            // identical col
            if matrix[col.x][col.y] == "1" {
                return false
            }
            
            // left col
            if vectorFirst.x > 0 {
                if matrix[col.x - 1][col.y] == "1" {
                    return false
                }
            }
            
            // right col
            if vectorFirst.x < valueRowSize - 1 {
                if matrix[col.x + 1][col.y] == "1" {
                    return false
                }
            }
        }
        return true
    }
    
    func covertNumeric(value: String) -> Int {
        var replaced = value.replacingOccurrences(of: ".", with: "")
        replaced = replaced.replacingOccurrences(of: ",", with: "")
        return Int(replaced)!
    }
}


