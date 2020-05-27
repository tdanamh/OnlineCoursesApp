import UIKit

class Answer {
    
    //MARK: Properties
    var answerContent: String
    var index: String
    var user: String
    var questionIndex: String
     
    init?(answerContent: String, index: String, user: String, questionIndex: String) {
        
        if answerContent.isEmpty {
            return nil
        }
        
        // Initialize stored properties.
        self.answerContent = answerContent
        self.index = index
        self.user = user
        self.questionIndex = questionIndex
        
    }
}
