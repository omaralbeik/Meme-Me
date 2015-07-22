//
//  EditVC.swift
//  MemeMe
//
//  Created by Omar Albeik on 22/07/15.
//  Copyright (c) 2015 Omar Albeik. All rights reserved.
//

import UIKit

class EditVC: UIViewController {
    
    var receivedMeme: MemeModel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meme = receivedMeme {
            imageView.image = UIImage(data: meme.memedImage)
        }
    }
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        println("edit button tapped")
        performSegueWithIdentifier("fromEditToAddSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromEditToAddSegue" {
            let addVC = segue.destinationViewController as! AddVC
            addVC.receivedMeme = self.receivedMeme
        }
    }
    
}
