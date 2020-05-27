import UIKit

class Question {
    
    var questionContent: String
    var index: String
    var user: String
    var courseIndex: String
    
    //MARK: Initialization
    init?(questionContent: String, index: String, user: String, courseIndex: String) {
        
        if questionContent.isEmpty {
            return nil
        }

        self.questionContent = questionContent
        self.index = index
        self.user = user
        self.courseIndex = courseIndex
        
    }
}
