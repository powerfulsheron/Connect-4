//
//  ViewController.swift
//  Puissance4
//
//  Copyright © 2018 Camille Guinaudeau. All rights reserved.
//

import UIKit

class ReglageViewController: UIViewController{
    
    @IBOutlet weak var musiqueSwitch: UISwitch!
    @IBOutlet weak var effetSwitch: UISwitch!
    @IBOutlet weak var backgroundSegment: UISegmentedControl!
    @IBOutlet weak var pionSegment: UISegmentedControl!
    
    let defaults = UserDefaults.standard
    
    @IBAction func musiqueAction(_ sender: Any) {
        if(musiqueSwitch.isOn){
            defaults.set(true, forKey: "isMusique")
        }else{
            defaults.set(false, forKey: "isMusique")
        }
    }
    @IBAction func effetAction(_ sender: Any) {
        if(effetSwitch.isOn){
            defaults.set(true, forKey: "isEffect")
        }else{
            defaults.set(false, forKey: "isEffect")
        }
    }
    @IBAction func backgroundAction(_ sender: Any) {
        defaults.set(backgroundSegment.selectedSegmentIndex, forKey: "backgroundColor")
    }
    @IBAction func pionAction(_ sender: Any) {
        defaults.set(pionSegment.selectedSegmentIndex, forKey: "pionType")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!defaults.bool(forKey: "isMusique")){
             musiqueSwitch.setOn(false, animated: false)
        }
        if(!defaults.bool(forKey: "isEffect")){
            effetSwitch.setOn(false, animated: false)
        }
        if(defaults.integer(forKey: "backgroundColor")==1){
            backgroundSegment.selectedSegmentIndex = 1
        }else if(defaults.integer(forKey: "backgroundColor")==2){
            backgroundSegment.selectedSegmentIndex = 2
        }else{
            backgroundSegment.selectedSegmentIndex = 0
        }
        if(defaults.integer(forKey: "pionType")==1){
            pionSegment.selectedSegmentIndex = 1
        }else{
            pionSegment.selectedSegmentIndex = 0
        }
    }
    
}


