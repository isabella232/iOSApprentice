//
//  ViewController.swift
//  BullsEye
//
//  Created by Jay on 10/11/14.
//  Copyright (c) 2014 Jay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var currentValue:Int = 50
    var targetValue:Int = 0
    var score = 0
    var round = 0
    
    @IBOutlet weak var slider:UISlider!
    @IBOutlet weak var targetLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    @IBOutlet weak var roundLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        
        slider.setThumbImage(thumbImageNormal, forState: .Normal)
        
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, forState: .Highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        
        let trackLeftImage = UIImage(named: "SliderTrackLeft")
        let trackLeftResizable = trackLeftImage?.resizableImageWithCapInsets(insets)
        slider.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
        
        let trackRightImage = UIImage(named: "SliderTrackRight")
        
        let trackRightResizable = trackRightImage?.resizableImageWithCapInsets(insets)
        slider.setMaximumTrackImage(trackRightResizable, forState: .Normal)
        
        
        startNewGame()
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNewGame (){
        score = 0
        round = 0
        startNewRound()
    }
    
    func startNewRound() {
        round += 1
        targetValue = 1 + Int(arc4random_uniform(100))
        currentValue = 50
        slider.value = Float(currentValue)
    }
    
    func updateLabels(){
        targetLabel.text = "\(targetValue)"
        scoreLabel.text = "\(score)"
        roundLabel.text = "\(round)"
    }

    @IBAction func showAlert(){
        
        let difference = abs(targetValue - currentValue)
        
        var points = 100 - difference
        
        var title:String
        if difference == 0 {
            title = "就是这种酸爽！!"
            points += 100
        } else if difference < 5 {
            title = "梦想还是要有的，万一实现了呢！"
            if difference == 1 {
                points += 50
            }
        } else if difference < 10 {
            title = "温饱线"
        } else {
            title = "差之毫厘谬以千里"
        }
        
        score += points
        
        let message = "滑块值为:\(currentValue)" +
                      "\n 目标值为:\(targetValue)" +
                      "\n 本局获得 \(points) 点"
        
        let alert = UIAlertController(title:title, message:message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "确定", style: .Default, handler: {actin in
                                                                            self.startNewRound()
                                                                            self.updateLabels()
            
                                                                            })
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func sliderMoverd(slider:UISlider) {
        currentValue = lroundf(slider.value)
        
    }
    
    @IBAction func startOver(){
        startNewGame()
        updateLabels()
    }
}

