//
//  DetailViewController.swift
//  SpendPlan
//
//  Created by Gautham Sritharan on 2021-05-24.
//
import Foundation
import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var expenseTableView       : UITableView! {
        didSet {
            self.expenseTableView.delegate = self
            self.expenseTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var detailsDisplayView     : UIView!
    @IBOutlet weak var lblCategoryName        : UILabel!
    @IBOutlet weak var leftView               : UIView!
    @IBOutlet weak var pichartView            : UIView!
    @IBOutlet weak var categoryNameView       : UIView!
    @IBOutlet weak var pieChartLabelStackView : UIStackView!
    
    @IBOutlet var barBtnRefresh               : UIBarButtonItem!
    @IBOutlet var barBtnAddExpense            : UIBarButtonItem!
    
    @IBOutlet weak var lblSpent               : UILabel!
    @IBOutlet weak var lblRemaining           : UILabel!
    @IBOutlet weak var lblBudget              : UILabel!
    
    @IBOutlet weak var lblColorOne            : UILabel!
    @IBOutlet weak var lblColorTwo            : UILabel!
    @IBOutlet weak var lblColorThree          : UILabel!
    @IBOutlet weak var lblColorFour           : UILabel!
    @IBOutlet weak var lblColorFive           : UILabel!
    
    @IBOutlet weak var box1View               : UIView!
    @IBOutlet weak var box2View               : UIView!
    @IBOutlet weak var box3View               : UIView!
    @IBOutlet weak var box4View               : UIView!
    @IBOutlet weak var box5View               : UIView!
    
    // MARK : - Variables
    
    let context              = (UIApplication.shared.delegate as!
                                    AppDelegate).persistentContainer.viewContext
    var managedObjectContext : NSManagedObjectContext? = nil
    
    var expenseTable         : UITableView?
    let viewPieChart         = PieChartView()
    var detailViewController : DetailViewController? = nil
    var addExpenseVC         : AddExpenseVC? = nil
    var expense              : [Expense]?
    var category             : Category?
    var expensePlaceholder   : Expense?
    
    var isEditMode           : Bool? = false
    
    let cellIdentifier       = "ExpenseTVCell"
    let eventStore           = EKEventStore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()

        expenseTableView.register(UINib(nibName: "ExpenseTVCell", bundle: nil), forCellReuseIdentifier: "ExpenseTVCell")
        countClick()
    }
    
    
    func configUI() {
        
        lblCategoryName.text = "\(category?.name ?? "Category")"
        lblBudget.text = "£ \(category?.budget ?? 0.00)"
        lblSpent.text = "£ 0.0"
        lblRemaining.text = "£ \(category?.budget ?? 0.00)"
        
        let padding: CGFloat = 20
        let height = (pichartView.frame.height - padding * 3)
        
        viewPieChart.frame = CGRect(
            x: 0, y: padding, width: pichartView.frame.size.width, height: height
        )
        
        viewPieChart.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.5647058824, green: 0.04705882353, blue: 0.2470588235, alpha: 1), name: "ColorOne",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.7803921569, green: 0, blue: 0.2235294118, alpha: 1), name: "ColorTwo",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 1, green: 0.3411764706, blue: 0.2, alpha: 1), name: "ColorThree",value: 0),
            LabelledSegment(color: #colorLiteral(red: 1, green: 0.7647058824, blue: 0, alpha: 1), name: "ColorFour", value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.8549019608, green: 0.968627451, blue: 0.6509803922, alpha: 1), name: "ColorFive", value: 0)
        ]
        
        if (category === nil){
            barBtnAddExpense.isEnabled = false
            self.pieChartLabelStackView.isHidden = true
            self.pichartView.isHidden = true
        }
        
        viewPieChart.segmentLabelFont = .systemFont(ofSize: 10)
        pichartView.addSubview(viewPieChart)
        
        categoryNameView.layer.cornerRadius = 5
        categoryNameView.layer.borderWidth = 2
        categoryNameView.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        
        box1View.layer.cornerRadius = box1View.bounds.size.width/2
        box2View.layer.cornerRadius = box1View.bounds.size.width/2
        box3View.layer.cornerRadius = box1View.bounds.size.width/2;
        box4View.layer.cornerRadius = box1View.bounds.size.width/2;
        box5View.layer.cornerRadius = box1View.bounds.size.width/2;
    }
    
    // MARK: - Segue actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendCategory" {
            let controller = segue.destination as! AddExpenseVC
            
            controller.category = self.category
            controller.expenseTable = self.expenseTableView
            controller.isEditMode = self.isEditMode
            controller.expensePlaceholder = self.expensePlaceholder
            addExpenseVC = controller
        }
    }
    
    // MARK: - Refrsh Button click
    
    @IBAction func didTapOnRefreshBtn(_ sender: Any) {
        if let e = (self.category?.expense?.allObjects) as? [Expense] {
            
            var totalSpent:Float = 0
            for exp in e {
                totalSpent += exp.amount
            }
            
            lblBudget.text = "£ \(category?.budget ?? 0.0)"
            lblSpent.text = "£ \(round(Double(totalSpent) * 100)/100.0)"
            lblRemaining.text = "£ \(round((category!.budget - totalSpent) * 100)/100.0)"
            addPieChart(exps :e, spentAmount : totalSpent)
        }
    }
    
    // MARK: - Piechart View
    
    func addPieChart(exps : [Expense], spentAmount : Float){
        
        resetPieChartToDefault()
        let expsR = exps.sorted(by: {$0.amount > $1.amount})
        var other:Float = 0
        var labeltags: [String] = ["N/A", "N/A", "N/A","N/A","N/A"]
        
        for (index, element) in expsR.enumerated() {
            
            if(index < 4){
                viewPieChart.segments[index].value = CGFloat(element.amount/spentAmount*100)
                labeltags[index] = element.name!
            }else{
                other += element.amount
            }
        }
        
        if other > 0  {
            viewPieChart.segments[4].value = CGFloat(other/spentAmount*100)
            labeltags[4] = "Other"
        }
        
        lblColorOne.text = labeltags[0]
        lblColorTwo.text = labeltags[1]
        lblColorThree.text = labeltags[2]
        lblColorFour.text = labeltags[3]
        lblColorFive.text = labeltags[4]
        
    }
    
    func resetPieChartToDefault(){
        
        viewPieChart.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.5647058824, green: 0.04705882353, blue: 0.2470588235, alpha: 1), name: "ColorOne",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.7803921569, green: 0, blue: 0.2235294118, alpha: 1), name: "ColorTwo",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 1, green: 0.3411764706, blue: 0.2, alpha: 1), name: "ColorThree",value: 0),
            LabelledSegment(color: #colorLiteral(red: 1, green: 0.7647058824, blue: 0, alpha: 1), name: "ColorFour", value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.8549019608, green: 0.968627451, blue: 0.6509803922, alpha: 1), name: "ColorFive", value: 0)
        ]
        
        lblColorOne.text = "N/A"
        lblColorTwo.text = "N/A"
        lblColorThree.text = "N/A"
        lblColorFour.text =  "N/A"
        lblColorFive.text = "N/A"
    }
    
    // MARK: - Counter
    
    func countClick(){
        self.category?.setValue(self.category!.clicks + 1, forKey: "clicks")
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exps = (self.category?.expense?.allObjects) as? [Expense] {
            if exps.count == 0 {
                self.pieChartLabelStackView.isHidden = true
                self.pichartView.isHidden = true
                self.expenseTableView.setEmptyMessage("No expenses added for this category", #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
            } else {
                resetPieChartToDefault()
                self.pieChartLabelStackView.isHidden = false
                self.pichartView.isHidden = false
                self.expenseTableView.restore()
            }
            return exps.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.category?.expense?.allObjects) as? [Expense]
        
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditMode = true
            self.expensePlaceholder = expenseList![indexPath.row]
            
            self.performSegue(withIdentifier: "sendCategory", sender: expenseList![indexPath.row])
            self.isEditMode = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.category?.expense?.allObjects) as? [Expense]
        
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete expense: ", yesAction: {
                () in
                print("expense deleted",expenseList![indexPath.row])
                do {
                    
                    let removingExpense = expenseList![indexPath.row]
                    _ = self.deleteCalendarEvent(self.eventStore, removingExpense)
                    self.category?.removeFromExpense(removingExpense)
                    let context = self.context
                    
                    try context.save()
                    self.expenseTableView.reloadData()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ExpenseTVCell = self.expenseTableView.dequeueReusableCell(withIdentifier: "ExpenseTVCell") as! ExpenseTVCell
        
        if var e = (self.category?.expense?.allObjects) as? [Expense] {
            
            let datapoint = e[indexPath.row]
            cell.lblExpenseName.text = datapoint.name
            cell.lblBudget.text = "£ \(datapoint.amount)"
            cell.lblNote.text = datapoint.notes
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            cell.lblDueDate.text = formatter.string(from: datapoint.dueDate ?? Date())
            
            switch datapoint.occurance {
            case 0:
                cell.lblOccurance.text = "Off"
            case 1:
                cell.lblOccurance.text = "Daily"
            case 2:
                cell.lblOccurance.text = "Weekly"
            case 3:
                cell.lblOccurance.text = "Monthly"
            default:
                cell.lblOccurance.text = "Off"
            }

            if datapoint.remainder == true {
                cell.lblRemainder.text = "On"
            } else {
                cell.lblRemainder.text = "Off"
            }
            
            var totalSpent:Float = 0
            for exp in e {
                totalSpent += exp.amount
            }
            
            lblSpent.text = "£ \(round(Double(totalSpent) * 100)/100.0)"
            lblRemaining.text = "£ \(round((category!.budget - totalSpent) * 100)/100.0)"
            cell.budgetProgressBar.progress = CGFloat(e[indexPath.row].amount/category!.budget)
            addPieChart(exps :e, spentAmount : totalSpent)
        }
        return cell
    }
    
    // MARK: - Calendar Event Handler
    // Removes an event from the EKEventStore
    func deleteCalendarEvent(_ eventStore: EKEventStore, _ expense:Expense) -> Bool {
        
        if let calendarId = expense.calendarId {
            let eventToRemove = eventStore.event(withIdentifier: calendarId)
            if eventToRemove != nil {
                do {
                    try eventStore.remove(eventToRemove!, span: .thisEvent)
                    return true
                } catch {
                    return false
                }
            }
        }
        
        return true;
    }
}
