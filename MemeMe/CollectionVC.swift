//
//  CollectionVC.swift
//  MemeMe
//
//  Created by Omar Albeik on 22/07/15.
//  Copyright (c) 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Class variables:
    var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    
    //MARK: View methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
    }
    
    
    // collection view methods:
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let thisMeme = fetchedResultController.objectAtIndexPath(indexPath) as! MemeModel
        
        cell.topTextLabel.text = thisMeme.topText
        cell.bottomTextLabel.text = thisMeme.bottomText
        cell.imageView.image = UIImage(data: thisMeme.image)
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("fromCollectionToEdit", sender: nil)
    }
    
    
    // UICollectionViewFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSizeMake(picDimension, picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(leftRightInset, leftRightInset , leftRightInset, leftRightInset)
    }
    
    
    // NSFetchedResultsController methods:
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: memeFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func memeFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "MemeModel")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
    
    
    // prepareForSegue:
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromCollectionToEdit" {
            let editVC = segue.destinationViewController as! EditVC
            let thisMeme = fetchedResultController.objectAtIndexPath(collectionView.indexPathsForSelectedItems().first as! NSIndexPath) as! MemeModel
            println(thisMeme.topText)
            editVC.receivedMeme = thisMeme
        }
    }
    
}
