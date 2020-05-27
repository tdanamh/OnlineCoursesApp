//  ViewCourseViewController.swift
//  Proiect1
//
//  Created by Dana Tudor on 03/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.

import UIKit
import FirebaseDatabase

class ViewCourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //MARK: Properties
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var courseContentTextView: UITextView!
    
    @IBOutlet weak var questionTableView: UITableView!
    
    @IBOutlet weak var coursePhotoView: UIImageView!
    
    var course: Course?
    
    var questions = [Question]()
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let course = course {
            courseNameLabel.text = course.name
            courseContentTextView.text = course.courseContent
            coursePhotoView.image = course.coursePhoto
        }
        
        loadQuestions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "QuestionTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? QuestionTableViewCell else {
            fatalError("The dequeued cell is not an instance of QuestionTableViewCell. ")
        }
        
        let question = questions[indexPath.row]
        
        cell.questionLabel.text = question.questionContent
        cell.questionUserLabel.text = question.user
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case "addQuestion":
            guard let addQuestionViewController = segue.destination as? AddQuestionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            addQuestionViewController.courseIndex = course?.index
        
            
        case "showAnswers":
            guard let answersTableViewController = segue.destination as? AnswersTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedQuestionCell = sender as? QuestionTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = self.questionTableView.indexPath(for: selectedQuestionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedQuestion = questions[indexPath.row]

            answersTableViewController.question = selectedQuestion
          
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    //MARK: Actions
    @IBAction func unwindToQuestionList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? AddQuestionViewController, let question = sourceViewController.question {
    
            let questionContent = question.questionContent
            let questionIndex = question.index
            let questionUser = question.user
            let questionCourseIndex = question.courseIndex
            
            // Save a new added question in Firebase
            let postRef = self.ref.child("questions")
            
            postRef.child(questionIndex).setValue(["content": questionContent, "courseIndex": questionCourseIndex, "index": questionIndex, "user": questionUser])
        }
    }
    
    private func loadQuestions() {
        
        let postRef = self.ref.child("questions")
        
        postRef.observe(.childAdded, with: { (snapshot) -> Void in
            let questionData = snapshot.value as? [String: AnyObject] ?? [:]
            
            let content = questionData["content"] as! String
            let courseIndex = questionData["courseIndex"] as! String
            let index = questionData["index"] as! String
            let user = questionData["user"] as! String
            
            if courseIndex == self.course?.index {
                guard let question = Question(questionContent: content, index: index, user: user, courseIndex: courseIndex) else {
                    fatalError("Unable to instantiate question")
                }
                self.questions.append(question)
                self.questionTableView.insertRows(at: [IndexPath(row: self.questions.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
            }
            
        })
        
    }

}
