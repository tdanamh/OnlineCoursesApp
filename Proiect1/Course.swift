//  Course.swift
//  Proiect1
//  Created by Dana Tudor on 03/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.

import UIKit

class Course : Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.index == rhs.index
    }

    //MARK: Properties
    var name: String
    var coursePhoto: UIImage?
    var courseContent: String
    var index: String
    
    //MARK: Initialization
    init?(name: String, coursePhoto: UIImage?, courseContent: String, index: String) {
        
        if name.isEmpty {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.coursePhoto = coursePhoto
        self.courseContent = courseContent
        self.index = index
        
    }
    
}
