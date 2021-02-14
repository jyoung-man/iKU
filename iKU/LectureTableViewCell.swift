//
//  LectureTableViewCell.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit

class LectureTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var profLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
