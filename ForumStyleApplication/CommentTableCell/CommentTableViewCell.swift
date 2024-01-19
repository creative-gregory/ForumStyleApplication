//
//  CommentTableViewCell.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/15/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func deleteButton(cell: UITableViewCell)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var delegate: CommentCellDelegate?
    

    @IBAction func tableDelete(_ sender: Any) {
        delegate?.deleteButton(cell: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
