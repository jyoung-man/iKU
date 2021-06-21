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

        // Configure the view for the selected state
    }
}
