//
//  ViewController.swift
//  hustle-mode
//
//  Created by Mark Price on 6/17/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var cloudHolder: UIView!
    @IBOutlet weak var rocket: UIImageView!
    @IBOutlet weak var inptBox: UITextField!
    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var taxTbl: UITableView!
    @IBOutlet weak var salesTaxLbl: UILabel!
    @IBOutlet weak var taxTotal: UILabel!
    
    var player: AVAudioPlayer!
    var taxes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taxTbl.dataSource = self
        
        self.inptBox.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        openAnimation()
    }
    
    func calcTaxTotal() {
        var taxAmtTotal = Double(0)
        for tax in taxes {
            let newTax = (tax as NSString).doubleValue
            taxAmtTotal = taxAmtTotal + newTax
        }
        taxTotal.text = String(format: "$%.2f", taxAmtTotal)
    }
    
    func parseTaxAmt(tax: String) -> String {
        let corTax = tax.replacingOccurrences(of: "$", with: "")
        return corTax
    }

    @IBAction func btnClick(_ sender: Any) {
        let taxAmt = parseTaxAmt(tax: self.inptBox.text!)
        
        taxes.append(taxAmt)
        taxTbl.beginUpdates()
        taxTbl.insertRows(at: [
            NSIndexPath(row: taxes.count-1, section: 0) as IndexPath
            ], with: .automatic)
        taxTbl.endUpdates()
        self.inptBox.text = ""
        startAnimation()
    }
    
    func startAnimation() {
        let path = Bundle.main.path(forResource: "Cash", ofType: "wav")!
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        player.play()
        UIView.animate(withDuration: 2.3, animations: {
            self.rocket.frame = CGRect(x: 50, y: 20, width: 272, height: 283)
            self.rocket.rotate360Degrees()
        }) { (finished) in
            self.inptBox.isHidden = false
            self.enterBtn.isHidden = false
            self.taxTbl.isHidden = false
            self.salesTaxLbl.isHidden = false
            self.taxTotal.isHidden = false
            
            self.calcTaxTotal()
        }
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            self.inptBox.text = amountString
        }
    }
    
    func openAnimation() {
        self.inptBox.isHidden = true
        self.enterBtn.isHidden = true
        self.taxTbl.isHidden = true
        self.salesTaxLbl.isHidden = true
        self.taxTotal.isHidden = true
        
        taxTotal.textAlignment = .center
        
        cloudHolder.isHidden = false
        
        startAnimation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        
        cell.textLabel?.textAlignment = .center
        
        let text = taxes[indexPath.row]
        
        cell.textLabel?.text = "$" + text
        
        return cell
    }
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}

