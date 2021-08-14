//
//  LectureCell.swift
//  iKU
//
//  Created by 박재영 on 2021/03/16.
//

import UIKit
import RxSwift

class LectureCell: UITableViewCell {
    
    @IBOutlet weak var lecCellView: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var profAndNumberLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.isSelected {
            lecCellView.backgroundColor = UIColor(red: 6/255, green: 107/255, blue: 64/255, alpha: 0.05)
        }
        else {
            lecCellView.backgroundColor = .white
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
    }
}
