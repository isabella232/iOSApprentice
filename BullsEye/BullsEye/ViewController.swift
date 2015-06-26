//
//  ViewController.swift
//  BullsEye
//
//  Created by Jay on 15/6/8.
//  Copyright (c) 2015年 look4us. All rights reserved.
//

import UIKit

import QuartzCore

class ViewController: UIViewController {

    var currentValue = 0
    
    var targetValue = 0
    
    var score = 0
    
    var round = 0
    
    
    @IBOutlet weak var slider: UISlider!
  
    @IBOutlet weak var targetLabel: UILabel!
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    @IBOutlet weak var roundLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        startNewGame()
        
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        
        slider.setThumbImage(thumbImageNormal, forState: .Normal)
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        
        slider.setThumbImage(thumbImageHighlighted, forState: .Highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft"){
            
            let trackLeftResizable = trackLeftImage.resizableImageWithCapInsets(insets)
            
            slider.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
        }
        
        if let trackRightImage = UIImage(named: "SliderTrackRight"){
            
            let trackRightResizable = trackRightImage.resizableImageWithCapInsets(insets)
            
            slider.setMaximumTrackImage(trackRightResizable, forState: .Normal)
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showAlert(){
        
        let difference = abs(targetValue - currentValue)
        
        var points = 100 - difference
        
        var title:String
        
        if difference == 0 {
        
            title = "哎吆，不错哦!"
            
            points += 100
        
        } else if difference < 5 {
            
            title = "差一点点"
            
            if difference == 1 {
            
                points += 50
                
            }
            
        } else if difference < 10 {
        
            title = "梦想还是要有的"
            
        }
            
        else {
        
            title = "你是个好人 ..."
            
        }
        
        score += points
        
        let message = "目标值：\(targetValue) \n 滑块值：\(currentValue) \n 得分：\(points)"
        
        
        let alert = UIAlertController(title: title,message:message,preferredStyle:.Alert)

        
        let action = UIAlertAction(title: "OK", style: .Default, handler: {action in self.startNewRound()})
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderMoved(slider:UISlider){
        
        currentValue = lroundf(slider.value)
    
    }
    
    @IBAction func startOver(){
        
        startNewGame()
        
        updateLabels()
        
        let transition = CATransition()
        
        transition.type = kCATransitionFade
        
        transition.duration = 1
        
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
    }
    
    func startNewGame(){
        
        score = 0
        round = 0
        
        startNewRound()
    }
    
    func startNewRound(){
        
        round += 1
        
        currentValue = 50
        
        slider.value = Float(currentValue)
        
        targetValue = 1 + Int(arc4random_uniform(100))
        
        updateLabels()
        
    }
    
    func updateLabels(){
        
        
        targetLabel.text = String(targetValue)
        
        scoreLabel.text = String(score)
        
        roundLabel.text = String(round)
    }
    
    
}

