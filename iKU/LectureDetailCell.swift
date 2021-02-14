	//
//  LectureDetailCell.swift
//  iKU
//
//  Created by 박재영 on 2021/02/13.
//

import UIKit

class LectureDetailCell: UITableViewCell {

    @IBOutlet weak var sectionImage: UIImageView!
    @IBOutlet weak var cellContents: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
