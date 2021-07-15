//
//  AddExpenseVC.swift
//  SpendPlan
//
//  Created by Gautham Sritharan on 2021-05-25.
//


import UIKit
import EventKit
import EventKitUI
import CoreData

class AddExpenseVC: UIViewController, EKEventEditViewDelegate {
    
    
    // MARK: - Outlets
    
    @IBOutlet var expenseNameTF            : UITextField!
    @IBOutlet var amountTF                 : UITextField!
    @IBOutlet var expenseNoteTV            : UITextField!
    @IBOutlet var dueDatePicker            : UIDatePicker!
    @IBOutlet var addToCalendarSwitch      : UISwitch!
    @IBOutlet var remainderSegementControl : UISegmentedControl!
    @IBOutlet weak var bgView              : UIView!
    
    @IBOutlet var btnAddExpense            : UIButton!
    @IBOutlet var btnCancel                : UIButton!
    
    // MARK: - Variables
    
    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext
    
    var expenseTable      : UITableView?
    var expenses          : [Expense]?
    var category          : Category?
    let eventStore        = EKEventStore()
    var expensePlaceholder: Expense?
    var time              = Date()
    var isEditMode        : Bool? = false
    var calendarIdentifier: String = ""
    var eventIdentifier   : String?
    var editingExpense    : Expense? = nil
    weak var delegate     : ItemActionDelegate?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        
        addToCalendarSwitch.isOn = false
        dueDatePicker.minimumDate = Date()
        
        if (isEditMode!) {
            if let expense = expensePlaceholder {
                expenseNameTF.text = expense.name
                amountTF.text = "\(expense.amount)"
                expenseNoteTV.text = expense.notes
                addToCalendarSwitch.isOn = expense.remainder
                dueDatePicker.date = expense.dueDate!
                remainderSegementControl.selectedSegmentIndex =  Int(expense.occurance)
            }
        }
        expenseNameTF.becomeFirstResponder()
        
        bgView.layer.cornerRadius = 5
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnAddExpense.layer.cornerRadius = 5
        btnAddExpense.layer.borderWidth = 1
        btnAddExpense.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnCancel.layer.cornerRadius = 5
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func clearField(){
        self.expenseNameTF.text = ""
        self.amountTF.text = ""
        self.expenseNoteTV.text = ""
    }
    
    @IBAction func handleAddBtnClick(_ sender: Any) {
        
        var containsNumber : Bool = false
        let budgetAmount = amountTF.text
        let decimalCharacters = CharacterSet.decimalDigits
        
        
        let decimalRange = budgetAmount!.rangeOfCharacter(from: decimalCharacters)
        if decimalRange != nil {
            containsNumber = true
        }
        
        let notification = addToCalendarSwitch.isOn
        
        if expenseNameTF.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense name can't be empty", caller: self)
        } else if amountTF.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense amount can't be empty", caller: self)
        } else if containsNumber == false {
            Utilities.showInformationAlert(title: "Error", message: "Enter a valid expense amount", caller: self)
        } else {
            var newExpense = Expense(context: self.context)
            
            if(self.isEditMode ?? false){
                newExpense = self.expensePlaceholder!
            } else{
                newExpense = Expense(context: self.context)
                handleCancelBtnClick("cancel")
            }
            newExpense.name = expenseNameTF.text!
            newExpense.amount = (amountTF.text! as NSString).floatValue
            newExpense.dueDate = dueDatePicker.date
            newExpense.occurance = Int64(remainderSegementControl.selectedSegmentIndex)
            newExpense.notes = expenseNoteTV.text!
      
            let expense = expensePlaceholder ?? Expense(context: context)
            
            if isEditMode == true {
                // Print
            } else {
                newExpense.calendarId = UUID().uuidString
            }

            if isEditMode == true {
                
                if addToCalendarSwitch.isOn {
                    print("Edit mode on")
                    
                    let calendarId = self.CalanderEvent(expense, notification)
                    expense.setValue(calendarId,forKey: "calendarId")
                } else {
                    print("Edit mode off")
                    
                    if let _id = expense.calendarId {
                        _ = deleteCalendarEvent(eventStore, eventId: _id )
                    }
                }
            } else {
                if addToCalendarSwitch.isOn {
                    
                    let calendarId = self.CalanderEvent(expense, notification)
                    expense.setValue(calendarId,forKey: "calendarId")
                    
                }
            }
            newExpense.remainder = addToCalendarSwitch.isOn
            newExpense.calendarId = eventIdentifier
            category?.addToExpense(newExpense)

            do {
                try self.context.save()
                let alert = UIAlertController(title: "Success", message: "Expense Saved", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true) {
                    self.clearField()
                }
                dismiss(animated: true)
                expenseTable?.reloadData()
                
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getExpense() {
        let e = (category?.expense?.allObjects) as! [Expense]
        e.forEach{exp in print(exp.amount)}
    }
    
    @IBAction func handleCancelBtnClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Calander Event
    
    func CalanderEvent(_ Expense: Expense, _ AddToCal:Bool) -> String?
    {
        let eventStore = EKEventStore()
        var calendarIdentifier:String? = ""
        
        if isEditMode == true
        {
            
            if(AddToCal)
            {
                if(Expense.calendarId == nil)
                {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized)
                    {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.createCalendarEvent(eventStore, Expense)
                        })
                    } else {
                        calendarIdentifier = self.createCalendarEvent(eventStore,Expense)
                        
                    }
                }
                else
                {
                    // Delete and create a new calendar event
                    _ = deleteCalendarEvent(eventStore, eventId: Expense.calendarId ?? "")
                    calendarIdentifier = self.createCalendarEvent(eventStore,Expense)
                }
            }else
            {
                _ = deleteCalendarEvent(eventStore, eventId: Expense.calendarId ?? "")
            }
        }
        else if AddToCal// This is straight forward add if true don't add if false
        {
            
            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .event, completion: {
                    granted, error in
                    calendarIdentifier = self.createCalendarEvent(eventStore, Expense)
                })
            } else {
                calendarIdentifier = self.createCalendarEvent(eventStore,Expense)
            }
        }
        
        return calendarIdentifier;
    }
    
    // Removes an event from the EKEventStore
    func deleteCalendarEvent(_ eventStore: EKEventStore, eventId:String) -> Bool {
        
        let event = eventStore.event(withIdentifier: eventId)
        if (event == nil)
        {
            return false;
        }
        do {
            var startDate=NSDate().addingTimeInterval(-60*60*24)
            var endDate=NSDate().addingTimeInterval(60*60*24*3)
            var predicate2 = eventStore.predicateForEvents(withStart: dueDatePicker.date, end: dueDatePicker.date, calendars: nil)
            
           // println("startDate:\(startDate) endDate:\(endDate)")
            
            var eV = eventStore.events(matching: predicate2) as [EKEvent]?
            
            if eV != nil {
                try eventStore.remove(event!, span: EKSpan.thisEvent, commit: true)
            
            }
            
        } catch {
            fatalError("Failed to save event with error : \(error)")
            //return false
        }
        return true
    }
    
    // Creates an event in the EKEventStore
    func createCalendarEvent(_ eventStore: EKEventStore, _ Expense:Expense) -> String? {
        
        let event = EKEvent(eventStore: eventStore)
        // let calendar = Calendar.current
        event.title = expenseNameTF.text
        event.startDate = dueDatePicker.date
        event.notes = expenseNoteTV.text
        event.endDate = dueDatePicker.date
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let selectedOccurenceValue = self.remainderSegementControl.titleForSegment(at: self.remainderSegementControl.selectedSegmentIndex)
        var rule: EKRecurrenceFrequency? = nil
        switch selectedOccurenceValue! {
        case "One Off":
            rule = nil
        case "Daily":
            rule = .daily
        case "Weekly":
            rule = .weekly
        case "Monthly":
            rule = .monthly
        default:
            rule = nil
        }
        
        if rule != nil {
            let recurrenceRule = EKRecurrenceRule(recurrenceWith: rule!, interval: 1, end: nil)
            event.addRecurrenceRule(recurrenceRule)
        }
                
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            eventIdentifier = event.eventIdentifier ?? "No-ID"
            return event.eventIdentifier
        } catch {
            fatalError("Failed to save event with error : \(error)")
            //return nil
        }
    }
    
}
