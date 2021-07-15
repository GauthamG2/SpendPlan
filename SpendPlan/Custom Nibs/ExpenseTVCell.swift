//
//  ExpenseTVCell.swift
//  SpendingManagementTool
//
//  Created by Gautham Sritharan on 2021-05-24.
//

import UIKit

protocol ExpenseTVCellDelegate {
    func viewNotes(cell: ExpenseTVCell, sender button: UIButton, data: String)
}

class ExpenseTVCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var lblExpenseName: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblOccurance: UILabel!
    @IBOutlet weak var lblRemainder: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var budgetProgressBar: PlainHorizontalProgressBar!

    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        budgetProgressBar.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        budgetProgressBar.color = #colorLiteral(red: 0.01490245387, green: 0.2902517915, blue: 0.5488812327, alpha: 1)
        
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        bgView.layer.cornerRadius = 3
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
