//
//  LectureCell.swift
//  iKU
//
//  Created by 박재영 on 2021/03/16.
//

import UIKit

class LectureCell: UITableViewCell {
    
    @IBOutlet weak var lecCellView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var profAndNumberLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.isSelected {
            lecCellView.backgroundColor = UIColor(red: 0.772, green: 0.847, blue: 0.709, alpha: 1)
        }
        else {
            lecCellView.backgroundColor = .white
        }
    }
    
}
