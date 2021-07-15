//
//  MasterViewController.swift
//  SpendPlan
//
//  Created by Gautham Sritharan on 2021-05-24.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var categoryTableView: UITableView! {
        didSet {
            categoryTableView.delegate = self
            categoryTableView.dataSource = self
        }
    }
    @IBOutlet weak var btnSort: UIBarButtonItem!
    
    
    // MARK: - Variables
    
    var managedObjectContext    : NSManagedObjectContext? = nil
    
    var detailViewController    : DetailViewController? = nil
    var addCategoryVC           : AddCategoryVC? = nil
    
    
    var categories              : [Category] = []
    var categoryPlaceholder     : Category?
    var isEditMode              : Bool? = false
    var sortingMethod           = "clicks"
    var isAscendingOrder        = false
    var backgroundColor         = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let cellIdentifier          = "CategoryTVCellwer"
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.tableFooterView = UIView()
        
        categories = Utilities.fetchFromDBContext(entityName: "Category")
        
        let cellNib = UINib(nibName: "CategoryTVCell", bundle: nil)
        categoryTableView.register(cellNib, forCellReuseIdentifier:
                                    "CategoryTVCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
    }
    
    // MARK: - Insert New Object
    
    @objc
    func insertNewObject(_ sender: Any) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let newCategory = Category(context: context)
        //let newEvent = Event(context: context)
        
        newCategory.name = "Name"
        newCategory.budget = 1000.00
        newCategory.notes = "Notes"
        newCategory.categoryId = "12345"

        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
 
    
    // MARK: - Segues
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategoryDetails" {
            for cell in tableView.visibleCells {
                let indexPath: IndexPath = tableView.indexPath(for: cell)!
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.category = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                detailViewController = controller
            }}
        
        if segue.identifier == "addCategory" {
            let controller = segue.destination as! AddCategoryVC
            controller.categoryPlaceholder = categoryPlaceholder
            controller.categoryTable = self.tableView
            controller.isEditMode = self.isEditMode
            addCategoryVC = controller
        }
    }
    
    // MARK: - Sort category
    
    @IBAction func handleSortBtnclick(_ sender: Any) {
        do {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            
            fetchRequest.fetchBatchSize = 10
            
            let sortDescriptor = NSSortDescriptor(key: sortingMethod, ascending: isAscendingOrder)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if(sortingMethod == "clicks"){
                sortingMethod = "name"
                isAscendingOrder = true
                btnSort.image = UIImage(named: "outline_sort_by_alpha_black_24pt")
            }else{
                sortingMethod = "clicks"
                isAscendingOrder = false
                btnSort.image = UIImage(named: "outline_pin_white_24pt_1x")
            }

            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            try _fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
        catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if sectionInfo.numberOfObjects == 0 {
            self.categoryTableView.setEmptyMessage("No Categories", #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
        } else {
            self.categoryTableView.restore()
        }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryTVCell", for: indexPath) as! CategoryTVCell
        let category = fetchedResultsController.object(at: indexPath)
        cell.lblCategoryName.text = category.name
        cell.lblBudget.text = "£ " + String(category.budget)
        cell.lblNote.text = category.notes
        //cell.layer.borderColor = category.color as? CGColor
        cell.selectionStyle = .blue
        cell.cellBgView.backgroundColor = category.color as? UIColor
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent event: Category) {
        //        code
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Setting the batch size
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key
        let sortDescriptor = NSSortDescriptor(key: sortingMethod, ascending: isAscendingOrder)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditMode = true
            self.categoryPlaceholder = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "addCategory", sender: self)
            self.isEditMode = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Alert", message: "Do you want to delete the category: " + self.fetchedResultsController.object(at: indexPath).name!, yesAction: {() in
                let context = self.fetchedResultsController.managedObjectContext
                context.delete(self.fetchedResultsController.object(at: indexPath))
                
                self.performSegue(withIdentifier: "showCategoryDetails", sender: self)
                
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Category)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Category)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func showPopoverFrom(cell: CategoryTVCell, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: categoryTableView)
        showRect = categoryTableView.convert(showRect, to: view)
        showRect.origin.y -= 5
    }
    
    func autoSelectTableRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showCategoryDetails", sender: empty)
        }
    }
}

// MARK: - Extensions

extension MasterViewController: CategoryTVCellDelegate {
    func customCell(cell: CategoryTVCell, sender button: UIButton, data: String) {
        self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
    }
}

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
