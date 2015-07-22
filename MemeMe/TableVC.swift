//
//  TableVC.swift
//  MemeMe
//
//  Created by Omar Albeik on 22/07/15.
//  Copyright (c) 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData

class TableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    
    //MARK: Table methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! UITableViewCell
        let thisMeme = fetchedResultController.objectAtIndexPath(indexPath) as! MemeModel
        cell.imageView?.image = UIImage(data: thisMeme.memedImage)
        cell.textLabel?.text = thisMeme.topText
        cell.detailTextLabel?.text = thisMeme.bottomText
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        managedObjectContext.deleteObject(managedObject)
        managedObjectContext.save(nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("fromTableToEdit", sender: nil)
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
        tableView.reloadData()
    }
    
    // prepareForSegue:
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromTableToEdit" {
            let editVC = segue.destinationViewController as! EditVC
            let thisMeme = fetchedResultController.objectAtIndexPath(tableView.indexPathForSelectedRow()!) as! MemeModel
            editVC.receivedMeme = thisMeme
        }
    }
}