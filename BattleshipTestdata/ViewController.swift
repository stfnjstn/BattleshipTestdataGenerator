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
    @IBOutlet weak var shipSize: NSTextField!
    @IBOutlet weak var numberOfShips: NSTextField!
    @IBOutlet weak var numberOfTrainingData: NSTextField!
    @IBOutlet var resultField: NSTextView!
    @IBOutlet weak var csvSeparator: NSTextField!
    
    var valueRowSize = 0
    var valueShipSize = 0
    var valueShips = 0
    var valueTrainingData = 0
    var valueCSVSeparator = " "
    var mode = Mode.matrix
    
    var battleFields: [[[Int]]] = []
    
    @IBAction func modeChanged(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            mode = .matrix
        } else if sender.selectedSegment == 1 {
            mode = .array
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
        valueShipSize = covertNumeric(value: shipSize.cell!.title)
        valueShips = covertNumeric(value: numberOfShips.cell!.title)
        valueTrainingData = covertNumeric(value: numberOfTrainingData.cell!.title)
        valueCSVSeparator = csvSeparator.cell!.title
      
        battleFields = []
        
        for _ in 0..<valueTrainingData {
            battleFields.append(generateBattlefield())
        }
        
        resultField.string = battleFieldsToString()
        
    }
    
    func battleFieldsToString() -> String {
        var csvText = ""
        for battleField in battleFields {
            csvText.append(battleFieldToString(battleField: battleField))
        }
        return csvText
    }
    
    func battleFieldToString(battleField: [[Int]]) -> String {
        var matrixCSV = ""
        for i in 0..<valueRowSize {
            var row = battleField[i]
            var rowCSV = ""
            for j in 0..<valueRowSize {
                rowCSV.append(String(row[j]))
                if j < valueRowSize - 1 {
                    rowCSV.append(valueCSVSeparator)
                }
            }
            if mode != .array {
                rowCSV.append("\n")
            } else if i < valueRowSize - 1  {
                rowCSV.append(valueCSVSeparator)
            }
            matrixCSV.append(rowCSV)
        }
        if mode == .array {
            matrixCSV.append("\n")
        }
        if mode == .human {
            matrixCSV.append("\n")
        }
        return matrixCSV
    }
    
    func generateBattlefield()-> [[Int]] {
        var matrix = [[Int]]()
        
        for _ in 0..<valueRowSize {
            var row = [Int]()
            for _ in 0..<valueRowSize {
                row.append(0)
            }
            matrix.append(row)
            
        }
      
        var bSuccess = false
        var vector = Vector(x: 0, y: 0)
        for _ in 0..<valueShips {
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
                    vector.x = Int(arc4random_uniform(UInt32(valueRowSize - valueShipSize)))
                    vector.y = Int(arc4random_uniform(UInt32(valueRowSize)))
                    shipCoord.append(vector)
                    for i in 1..<valueShipSize {
                        shipCoord.append(Vector(x: vector.x + i, y: vector.y))
                    }
                    bSuccess = checkRulesHorizontal(shipCoord: shipCoord, matrix: matrix)
                } else {
                    vector.x = Int(arc4random_uniform(UInt32(valueRowSize)))
                    vector.y = Int(arc4random_uniform(UInt32(valueRowSize - valueShipSize)))
                    shipCoord.append(vector)
                    for i in 1..<valueShipSize {
                        shipCoord.append(Vector(x: vector.x, y: vector.y + i))
                    }
                    bSuccess = checkRulesVertical(shipCoord: shipCoord, matrix: matrix)
                }
            }
            
            // fillMatrix
            for cell in shipCoord {
                matrix[cell.x][cell.y] = 1
            }
        }
        return matrix
    }
    

    
    func checkRulesHorizontal(shipCoord: [Vector], matrix: [[Int]]) -> Bool {
        let vectorFirst = shipCoord.first!
        let vectorLast = shipCoord.last!
        
        // left
        if vectorFirst.x > 0 {
            if matrix[vectorFirst.x - 1][vectorFirst.y] == 1 {
                return false
            }
        }
        
        // right
        if vectorLast.x < valueRowSize - 1 {
            if matrix[vectorLast.x + 1][vectorLast.y] == 1 {
                return false
            }
        }
        
        // above
        if vectorFirst.y > 0 {
            // left upper corner
            if vectorFirst.x > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y - 1] == 1 {
                    return false
                }
            }
            // right upper corner
            if vectorLast.x < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y - 1] == 1 {
                    return false
                }
            }
            // upper row
            for col in shipCoord {
                if matrix[col.x][col.y - 1] == 1 {
                    return false
                }
            }
        }
        
        // below
        if vectorFirst.y < valueRowSize - 1 {
            // left lower corner
            if vectorFirst.x > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y + 1] == 1 {
                    return false
                }
            }
            // right lower corner
            if vectorLast.x < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y + 1] == 1 {
                    return false
                }
            }
            // lower row
            for col in shipCoord {
                if matrix[col.x][col.y + 1] == 1 {
                    return false
                }
            }
        }
        
        // identity
        if matrix[vectorFirst.x][vectorFirst.y] == 1 {
            return false
        }
        
        return true
    }

    func checkRulesVertical(shipCoord: [Vector], matrix: [[Int]]) -> Bool {
        let vectorFirst = shipCoord.first!
        let vectorLast = shipCoord.last!
        
        // top
        if vectorFirst.y > 0 {
            if matrix[vectorFirst.x][vectorFirst.y - 1] == 1 {
                return false
            }
        }
        
        // bottom
        if vectorLast.y < valueRowSize - 1 {
            if matrix[vectorLast.x][vectorLast.y + 1] == 1 {
                return false
            }
        }
        
        // left
        if vectorFirst.x > 0 {
            // left upper corner
            if vectorFirst.y > 0 {
                if matrix[vectorFirst.x - 1][vectorFirst.y - 1] == 1 {
                    return false
                }
            }
            
            // left lower corner
            if vectorLast.y < valueRowSize - 1 {
                if matrix[vectorLast.x - 1][vectorLast.y + 1] == 1 {
                    return false
                }
            }
            
            // left row
            for col in shipCoord {
                if matrix[col.x - 1][col.y] == 1 {
                    return false
                }
            }
        }
        
        // right
        if vectorFirst.x < valueRowSize - 1 {
            // right upper corner
            if vectorFirst.y > 0 {
                if matrix[vectorFirst.x + 1][vectorFirst.y - 1] == 1 {
                    return false
                }
            }
            
            // right lower corner
            if vectorLast.y < valueRowSize - 1 {
                if matrix[vectorLast.x + 1][vectorLast.y + 1] == 1 {
                    return false
                }
            }
            
            // right row
            for col in shipCoord {
                if matrix[col.x + 1][col.y] == 1 {
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


