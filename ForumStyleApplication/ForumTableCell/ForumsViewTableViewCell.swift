//
//  ForumsViewTableViewCell.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/14/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func deleteButton(cell: UITableViewCell)
    func likePost(cell: UITableViewCell)
}

class ForumsViewTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    
    var delegate: PostCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        contentLabel.numberOfLines = 999
        
        // Initialization code
        
//        contentTextView!.layer.borderWidth = 1
//        contentTextView!.layer.borderColor = UIColor.systemPurple.cgColor
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        delegate?.deleteButton(cell: self)
    }

    @IBAction func likePost(_ sender: Any) {
        delegate?.likePost(cell: self)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
