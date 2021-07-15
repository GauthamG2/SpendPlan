//
//  CategoryTVCell.swift
//  SpendingManagementTool
//
//  Created by Gautham Sritharan on 2021-05-24.
//

import UIKit

protocol CategoryTVCellDelegate {
    func customCell(cell: CategoryTVCell, sender button: UIButton, data: String)
}


class CategoryTVCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var cellBgView: UIView!
    
    // MARK: - Variables
    
    var cellDelegate: CategoryTVCellDelegate?
    var notes: String = "No notes available"
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellBgView.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        cellBgView.layer.borderWidth = 1
        cellBgView.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func handleNotesButtonClick(_ sender: Any) {
        self.cellDelegate?.customCell(cell: self, sender: sender as! UIButton, data: notes)
    }
    
    func commonInit(_ categoryName: String, budget: String, color: String, notes: String) {
        
    }
}
