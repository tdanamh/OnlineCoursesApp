//  CourseTableViewCell.swift
//  Proiect1
//  Created by Dana Tudor on 03/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.

import UIKit

class CourseTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var viewCourseButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
