//
//  AddVC.swift
//  MemeMe
//
//  Created by Omar Albeik on 22/07/15.
//  Copyright (c) 2015 Omar Albeik. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class AddVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Storyboard outlets:
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    //Class variables:
    let imagePicker = UIImagePickerController()
    var image: UIImage!
    var currentKeyboardHeight: CGFloat = 0.0
    var receivedMeme: MemeModel!
    var topTextEdited = false
    var bottomTextEdited = false
    
    //MARK: View methods:
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meme = receivedMeme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = UIImage(data: meme.image)
            topTextEdited = true
            bottomTextEdited = true
        }
        
        // disable camera button if camera not available
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            cameraButton.enabled = false
        }
        
        // set delegates:
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // set text fields text attributes:
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        //Looks for single or multiple taps to dismiss keyboard:
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topTextField {
            if topTextEdited == false {
                topTextEdited = true
                topTextField.text = ""
            }
        }
        if textField == bottomTextField {
            if bottomTextEdited == false {
                bottomTextEdited = true
                bottomTextField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    
    //MARK: Keyboard methods:
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        currentKeyboardHeight = 0
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        currentKeyboardHeight = 0
        
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        // fix 3d party keyboards bug, (by the way this bug is not solved in your app in AppStore)
        // for more info: http://stackoverflow.com/questions/25874975/cant-get-correct-value-of-keyboard-height-in-ios8
        let deltaHeight = keyboardSize.CGRectValue().height - currentKeyboardHeight
        currentKeyboardHeight = deltaHeight
        return currentKeyboardHeight
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: Storyboard actions:
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        // if user didn't choose image show error message, else show action menu
        if imageView.image == nil {
            var alert = UIAlertController(title: "No Image!", message: "Please add image before sharing.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let memedImage = generateMemedImage()
            let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            presentViewController(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = {
                button in
                // check if activity completed:
                if button.1 == true {
                    self.saveImage()
                    self.resetMeme()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    // presenting image picker
    @IBAction func cameraButtonTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [kUTTypeImage]
            imagePicker.allowsEditing = false
        }
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func galleryButtonTapped(sender: UIBarButtonItem) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    // Image picker methods:
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imageView.image = image
        
        // dismissing the image picker view
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Create memed image methods:
    func saveImage() -> UIImage {
        
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var managedObjectContext = appDelegate.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("MemeModel", inManagedObjectContext: managedObjectContext)
        let meme = MemeModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        meme.topText = topTextField.text
        meme.bottomText = bottomTextField.text
        
        let imageData = UIImageJPEGRepresentation(imageView.image, 1.0)
        meme.image = imageData
        
        let memedImageData = UIImageJPEGRepresentation(generateMemedImage(), 1.0)
        meme.memedImage = memedImageData
        
        // set current date to meme, so we can use it to sort memes in history table by date created
        meme.date = NSDate()
        
        // save meme to CoreData
        appDelegate.saveContext()
        
        return generateMemedImage()
    }
    
    func generateMemedImage() -> UIImage {
        
        // hide tollbars befor rendering an image
        topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // unhiding the tollbars after image is rendered
        topToolbar.hidden = false
        bottomToolbar.hidden = false
        
        return memedImage
    }
    
    // reset layout method:
    func resetMeme() {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextEdited = false
        bottomTextEdited = false
    }
    
}
