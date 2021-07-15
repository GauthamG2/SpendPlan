//
//  AddCategoryVC.swift
//  SpendPlan
//
//  Created by Gautham Sritharan on 2021-05-25.
//

import Foundation
import UIKit

class AddCategoryVC: UIViewController, UIColorPickerViewControllerDelegate  {
    
    // MARK: - Outlets
    
    @IBOutlet var categoryNameTF      : UITextField!
    @IBOutlet var categoryNotesTF     : UITextField!
    @IBOutlet var categoryBudgetTF    : UITextField!
    
    @IBOutlet weak var btnColorPicker : UIButton!
    
    @IBOutlet var btnAddCategory      : UIButton!
    @IBOutlet var btnCancel           : UIButton!
    
    @IBOutlet weak var bgView         : UIView!
    @IBOutlet weak var btnOrange      : UIButton!
    @IBOutlet weak var btnBlue        : UIButton!
    @IBOutlet weak var btnPurple      : UIButton!
    @IBOutlet weak var btnGreen       : UIButton!
    @IBOutlet weak var btnRed         : UIButton!
    @IBOutlet weak var btnYellow      : UIButton!
    @IBOutlet weak var btnWhite       : UIButton!
    
    // MARK: - Variables
    
    var noteColor                  : String?
    var saveFunction               : Utilities.saveFunctionType?
    var resetToDefaults            : Utilities.resetToDefaultsFunctionType?
    var categoryPlaceholder        : Category?
    var isEditMode                 : Bool? = false
    var categories                 : [Category]?
    var categoryTable              : UITableView?
    weak var delegate              : ItemActionDelegate?
    
    var bgColor                    : UIColor?

    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    
    // MARK: - LifeCycle
    
    override func viewDidDisappear(_ animated: Bool) {
        isEditMode=false
        categoryPlaceholder=nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        if (isEditMode!) {
            if let category = categoryPlaceholder {
                categoryNameTF.text = category.name
                categoryBudgetTF.text = "\(category.budget)"
                categoryNotesTF.text = category.notes
                bgColor = category.color as? UIColor
            }
        }
        categoryNameTF.becomeFirstResponder()
       
    }
    
    // MARK: - ConfigUI
    
    func configUI() {
        
        btnAddCategory.layer.borderWidth = 1
        btnAddCategory.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btnAddCategory.layer.cornerRadius = 5
        
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btnCancel.layer.cornerRadius = 5
        
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bgView.layer.cornerRadius = 5
    }
    
    // MARK: - Color Picker
    
    @IBAction func didTapOnColorPickerBtn(_ sender: Any) {
            let colorPickerVC = UIColorPickerViewController()
            colorPickerVC.delegate = self
            present(colorPickerVC, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        bgColor = color
        
    }
    
    // MARK: - Color Button actions
    
    @IBAction func handleBtnOrangeClick(_ sender: Any) {
        noteColor = "Orange"
        bgColor = #colorLiteral(red: 1, green: 0.5490196078, blue: 0, alpha: 1)
        btnOrange.layer.borderWidth = 1
        btnOrange.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnBlue.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnBlueClick(_ sender: Any) {
        noteColor = "Blue"
        bgColor = #colorLiteral(red: 0.6784313725, green: 0.8745098039, blue: 1, alpha: 1)
        btnBlue.layer.borderWidth = 1
        btnBlue.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnVioletClick(_ sender: Any) {
        noteColor = "Violet"
        bgColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        btnPurple.layer.borderWidth = 1
        btnPurple.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnBlue.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnGreenClick(_ sender: Any) {
        noteColor = "Green"
        bgColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        
        btnGreen.layer.borderWidth = 1
        btnGreen.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnBlue.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnRedClick(_ sender: Any) {
        noteColor = "Red"
        bgColor = #colorLiteral(red: 0.9647058824, green: 0.1568627451, blue: 0.09019607843, alpha: 1)
        
        btnRed.layer.borderWidth = 1
        btnRed.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnBlue.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnYellowClick(_ sender: Any) {
        noteColor = "Yellow"
        bgColor = #colorLiteral(red: 1, green: 0.9529411765, blue: 0.5019607843, alpha: 1)
        
        btnYellow.layer.borderWidth = 1
        btnYellow.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnBlue.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnWhite.layer.borderWidth = 0
    }
    
    @IBAction func handleBtnWhiteClick(_ sender: Any) {
        noteColor = "White"
        bgColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        btnWhite.layer.borderWidth = 1
        btnWhite.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btnOrange.layer.borderWidth = 0
        btnBlue.layer.borderWidth = 0
        btnPurple.layer.borderWidth = 0
        btnGreen.layer.borderWidth = 0
        btnRed.layer.borderWidth = 0
        btnYellow.layer.borderWidth = 0
    }
    
    
    @IBAction func handleCancelBtnClick(_ sender: Any) {
        dismiss(animated: true);
    }
    
    @IBAction func handleAddBtnClick(_ sender: Any) {
        if categoryNameTF.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Category name cannot be empty", caller: self)
        } else if categoryBudgetTF.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Budget cannot be empty", caller: self)
        } else {
            var newCategory:Category
            if(self.isEditMode ?? false){
                newCategory = self.categoryPlaceholder!
            }else{
                newCategory = Category(context: self.context)
                handleCancelBtnClick("Cancel")
            }
            newCategory.name = categoryNameTF.text!
            newCategory.budget = (categoryBudgetTF.text! as NSString).floatValue
            newCategory.notes = categoryNotesTF.text!
            newCategory.color = bgColor
            newCategory.categoryId = UUID().uuidString
            newCategory.clicks = 0

            do {
                try self.context.save()
                categoryTable?.reloadData()
                handleCancelBtnClick("Cancel")

            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

