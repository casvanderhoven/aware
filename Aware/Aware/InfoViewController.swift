//
//  InfoViewController.swift
//  Aware
//
//  Created by Cas van der Hoven on 17/01/2017.
//  Copyright © 2017 Cas van der Hoven. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var supportButton: UIButton!
    
    @IBAction func cancel() {
        dismiss(animated:true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        supportButton.layer.borderWidth = 0.8
        if(supportButton.isHighlighted) {
            supportButton.layer.borderColor = UIColor(white: 0.5, alpha:0.3).cgColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
